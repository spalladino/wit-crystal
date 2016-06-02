require "../src/wit"

# Quickstart example
# See https://wit.ai/l5t/Quickstart

access_token = ARGV.shift?
unless access_token
  puts "Usage: crystal examples/quickstart.cr <access-token>"
  exit
end

class QuickstartActions

  include Wit::Actions

  def say(session_id, context, message, confidence)
    p message
  end

  def merge(session_id, context, entities, msg, confidence)
    loc = first_entity_value entities, "location"
    context["loc"] = loc unless loc.nil?
    context
  end

  def error(session_id, context, error, confidence)
    p error.message
    context
  end

  def custom(action_name, session_id, context, confidence)
    case action_name
    when "fetch-weather"
      context["forecast"] = "sunny"
    else
      puts "Unknown action #{action_name}"
    end
    context
  end

  private def first_entity_value(entities, entity)
    if entities
      entities[entity][0]["value"].as_s rescue nil
    end
  end

end

client = Wit::App.new access_token, QuickstartActions.new, Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG }
client.interactive
