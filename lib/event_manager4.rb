require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(input_zipcode)
  input_zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address( #https://github.com/googleapis/google-api-ruby-client/blob/master/google-api-client/generated/google/apis/civicinfo_v2/service.rb
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def clean_phone(phone)
  clean_number = phone.gsub(/[^\d]/,"")
  if clean_number.size < 10 || clean_number.size > 11
    "Error. The number must have 10 digits or 11 digits if 1 is the first digit"
  elsif clean_number.size == 11 && clean_number[0] == "1"
    clean_number[1..10]
  elsif clean_number.size == 11 && clean_number[0] != "1"
    "Error. Unknown format"
  else
    clean_number
  end 
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir("output") unless Dir.exist? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager Initialized!"
puts

if File.exist? "event_attendees.csv"

  contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

  template_letter = File.read "form_letter.erb"
  erb_template = ERB.new template_letter

  contents.each do |row|
    id = row[0]
    name = row[:first_name]

    zipcode = clean_zipcode(row[:zipcode])

    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    save_thank_you_letter(id,form_letter)
  end

end