require 'icalendar'
require 'csv'
require 'active_support/time_with_zone'
require 'icalendar/tzinfo'

filename = ARGV.first

cal = Icalendar::Calendar.new

csv_options = { headers: :first_row, col_sep: ';' }

@tzid = 'Europe/Helsinki'
tz = TZInfo::Timezone.get @tzid
timezone = tz.ical_timezone DateTime.now
cal.add_timezone timezone

def icaldate(date)
  Icalendar::Values::DateTime.new date, 'tzid' => @tzid
end

CSV.open(filename, 'r:bom|utf-8', csv_options) do |csv|
  csv.each do |row|
    cal.event do |e|
      e.dtstart = icaldate DateTime.parse(row['Start'])
      e.dtend = icaldate DateTime.parse(row['End'])
      e.summary = "#{row['Group']}: #{row['Computer']} (#{row['ID']})"
      e.description = " Computer: #{row['Computer']}<br> ID: #{row['ID']}<br> Group: #{row['Group']}<br> Start: #{row['Start']}<br> End: #{row['End']}<br> Duration: #{row['Duration']}<br> Notes: #{row['Notes']}"
    end
  end
end

puts cal.to_ical
