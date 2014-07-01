#!/usr/bin/env ruby
# encoding: utf-8
#
# Utility to convert Teamviewer connection report to an ical file

require 'icalendar'
require 'csv'
require 'active_support/time_with_zone'
require 'icalendar/tzinfo'
require 'digest'

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
  md5 = Digest::MD5.new
  csv.each do |row|
    cal.event do |e|
      md5.update "#{row['Start']}+#{row['End']}+#{row['ID']}"
      e.uid = "#{md5.hexdigest}@tv.conv"

      e.dtstart = icaldate DateTime.parse(row['Start'])
      e.dtend = icaldate DateTime.parse(row['End'])

      e.summary = "#{row['Group']}: #{row['Computer']} (#{row['ID']})"
      e.description = <<EOD
Computer: #{row['Computer']}
ID: #{row['ID']}
Group: #{row['Group']}
Start: #{row['Start']}
End: #{row['End']}
Duration: #{row['Duration']}
Notes: #{row['Notes']}"
EOD
    end
  end
end

puts cal.to_ical
