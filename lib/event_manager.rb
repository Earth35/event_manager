require "csv"
require "sunlight-congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

class EventManager
  def initialize (csv, template)
    puts "Event manager initialized."
    @contents = CSV.open(csv, headers: true, header_converters: :symbol)
    @template = File.read(template)
    @erb_template = ERB.new(@template)
  end
  
  def execute
    @contents.each do |row|
      id = row[0]
      name = row[:first_name]
      zipcode = clean_zipcode(row[:zipcode])
      legislators = legislators_by_zipcode(zipcode)
      form_letter = @erb_template.result(binding)
      generate_letter(id, form_letter)
    end
  end
  
  private
  
  def clean_zipcode (code)
    code.to_s.rjust(5, "0")[0..4]
  end
  
  def legislators_by_zipcode (zipcode)
    legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
    legislator_names = get_legislator_names(legislators)
    legislators_string = legislator_names.join(", ")
  end
  
  def get_legislator_names (legislators)
    legislator_names = legislators.map do |legislator|
      "#{legislator.first_name} #{legislator.last_name}"
    end
    return legislator_names
  end
  
  def generate_letter (id, form_letter)
    Dir.mkdir("../output") unless Dir.exists?("../output")
    filename = "../output/thanks_#{id}.html"
    File.open(filename, 'w') do |file|
      file.puts form_letter
    end
  end
end

manager = EventManager.new("../event_attendees.csv", "../form_letter.erb")
manager.execute
