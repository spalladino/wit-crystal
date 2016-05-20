require "../src/wit"

access_token = ARGV.shift
REFERENCE_TIME = "2012-03-08"

client = Wit::App.new access_token
context = Wit::Context.new reference_time: Time.parse(REFERENCE_TIME, "%F")

r1 = client.message("Last week")
r2 = client.message("Last week", context)

puts "Understanding message 'Last week'"
puts " Without context:  #{r1.entities["datetime"][0]["value"]}"
puts " Ref #{REFERENCE_TIME}:   #{r2.entities["datetime"][0]["value"]}"
