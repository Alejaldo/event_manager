require "csv"

def clean_zipcode(input_zipcode)
  input_zipcode.to_s.rjust(5, "0")[0..4]
end

puts "EventManager Initialized!"
puts

if File.exist? "event_attendees.csv"

  contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

  contents.each do |row|
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode])

    puts "#{name} #{zipcode}"
  end

end