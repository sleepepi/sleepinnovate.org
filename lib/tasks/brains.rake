# frozen_string_literal: true

namespace :brains do
  desc "Import nightly Test My Brains CSVs."
  task nightly_import: :environment do
    reset_survey_counts
    parse_brain_csvs
  end
end

def reset_survey_counts
  User.update_all(brain_surveys_count: 0)
end

def parse_brain_csvs
  csv_files = Dir.glob(Rails.root.join("brains", "**", "*.csv"), File::FNM_CASEFOLD)
  csv_files.each do |csv_file|
    read_csv(csv_file)
  end
end

def read_csv(csv_file)
  current_line = 0
  CSV.parse(File.open(csv_file, "r:iso-8859-1:utf-8", &:read), headers: true) do |line|
    row = line.to_hash.with_indifferent_access
    print_header(row) if current_line.zero?
    print_row(row)
    increment_subject(row)
    current_line += 1
  end
end

def print_header(row)
  puts row.keys.inspect
end

def print_row(row)
  puts "Subject: #{subject_code(row)}"
  puts "Test ID: #{row["test_id"]}"
end

def subject_code(row)
  row["participant_id"]
end

def increment_subject(row)
  (subject_id, _subject_code) = remote_subjects.select { |_id, code| code == subject_code(row) }
  user = User.find_by(slice_subject_id: subject_id) if subject_id.present?
  if user
    user.increment!(:brain_surveys_count)
    puts "         #{subject_code(row)} surveys: #{user.brain_surveys_count}"
  else
    puts "         #{subject_code(row)} not found"
  end
  puts
end

def remote_subjects
  @remote_subjects ||= begin
    subjects = []
    page = 1
    loop do
      new_subjects = subjects_on_page(page)
      subjects += new_subjects.reject { |_id, code| (/^#{ENV["code_prefix"]}\d{5}$/ =~ code).nil? }
      page += 1
      break unless new_subjects.size == 20
    end
    subjects
  end
end

def subjects_on_page(page)
  params = { page: page }
  (json, _status) = Helpers::JsonRequest.get("#{SliceRecord.new.project_url}/subjects.json", params)
  return [] unless json
  subjects = json.collect do |subject_json|
    [subject_json["id"], subject_json["subject_code"]]
  end
  subjects
end
