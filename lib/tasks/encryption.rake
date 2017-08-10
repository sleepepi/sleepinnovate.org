# frozen_string_literal: true

namespace :encryption do
  desc "Rotates Key Encryption Key, fast but requires server restart. (MONTHLY)"
  task rotate_master_kek: :environment do
    prompt_db_backup
    kek = DataEncryptionKey.random_key_hex
    puts "Update in \"application.yml\":"
    puts "key_encryption_key:   \"#{kek}\""
    DataEncryptionKey.find_each do |dek|
      dek.reencrypt!(kek)
    end
  end

  desc "Rotates Data Encryption Keys, slow, but no server restart required. (YEARLY)"
  task rotate_dek: :environment do
    DataEncryptionKey.rotate_dek!
  end
end

def prompt_db_backup
  print "Did you backup the database? (y|N): "
  response = STDIN.gets.chomp.downcase[0]
  return if response == "y"
  puts "Task canceled."
  exit
end
