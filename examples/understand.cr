require "../src/wit"

USAGE = "Usage: crystal examples/understand.cr <access-token> <message>"

access_token = ARGV.shift?
unless access_token
  puts USAGE
  exit
end

message = ARGV.join(" ")
if message.strip.empty?
  puts USAGE
  exit
end

client = Wit::App.new access_token, logger: Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG }
response = client.message(message)
puts "Extracted entities from '#{message}'"
response.entities.each do |k,v|
  puts " #{k}=#{v.inspect}"
end
