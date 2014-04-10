#!/usr/bin/env ruby
input_dir_path = './data'
output_dir_path = './output'
total_processed = 0

matchers = [/.*\t.*\t8095\t.*/,
            /.*\t.*\t8184\t.*/,
            /.*\t.*\t4092\t.*/
           ]

input_logs = Dir.entries(input_dir_path).select{|f| f =~ /.*log/}

input_logs.each do |log_name|
  log_file = "#{input_dir_path}/#{log_name}"
  file_size = (File.size(log_file) / 1024000.to_f)
  puts "Processing #{log_file} (#{file_size.round(2)} MB)"

  cached_file = IO.readlines(log_file)

  header = cached_file.shift
  sap_number = /SAPNUMBER: (?<sapnumber>\d+)/.match(header)[:sapnumber]
  puts "SAPNUMBER: #{sap_number}"
  match_file = File.open("#{output_dir_path}/#{sap_number}.log", "a")
  miss_file = File.open("#{output_dir_path}/unmatched.log", "a")

  cached_file.each do |line|
    matched = false
    matchers.each do |matcher|
      if line =~ matcher
        matched = true
        match_file.write(line)
      end
    end
    miss_file.write(line) unless matched
  end

  match_file.close
  miss_file.close

  total_processed += file_size
  puts "Completed #{log_file} (#{total_processed.round(2)} MB total processed)"
end

