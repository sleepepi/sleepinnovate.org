# frozen_string_literal: true

namespace :brains do
  desc "Import nightly Test My Brains CSVs."
  task nightly_import: :environment do
    parse_brain_csvs
  end
end

def parse_brain_csvs
  FileUtils.mkpath Rails.root.join("brains", "archive")
  csv_files = Dir.glob(Rails.root.join("brains", "*.csv"), File::FNM_CASEFOLD)
  csv_files.each do |csv_file|
    read_csv(csv_file)
    FileUtils.mv csv_file, Rails.root.join("brains", "archive")
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
  puts "       Subject: #{subject_code(row)}"
  puts "         Event: #{event(row)}"
  puts "Battery Number: #{battery_number(row)}"
  puts "   Test Number: #{test_number(row)}"
  puts "     Test Name: #{test_name(row)}"
  puts "      Outcomes: #{test_outcomes(row)}"
end

def subject_code(row)
  row["userId"].to_s.gsub(event(row), "")
end

def event(row)
  row["userId"].to_s.gsub(/^#{ENV["code_prefix"]}\d{5}/, "")
end

def battery_number(row)
  row["batteryId"]
end

def test_number(row)
  row["testId"]
end

def test_name(row)
  row["testName"]
end

def test_outcomes(row)
  row["outcomes"]
end

def increment_subject(row)
  (subject_id, _subject_code) = Subject.remote_subjects.select { |_id, code| code == subject_code(row) }
  user = User.find_by(slice_subject_id: subject_id) if subject_id.present?
  if user
    user.brain_tests.create(
      event: event(row).gsub(/dash/, "-").downcase,
      battery_number: battery_number(row),
      test_name: test_name(row),
      test_number: test_number(row),
      test_outcomes: test_outcomes(row)
    )
    puts "         #{subject_code(row)} surveys: #{user.brain_surveys_count}"
  else
    puts "         #{subject_code(row)} not found"
  end
  puts
end
