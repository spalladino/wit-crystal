require "./wit/*"

require "json"
require "logger"
require "http"
require "secure_random"

module Wit
  WIT_API_HOST = ENV["WIT_URL"]? || "https://api.wit.ai"
  DEFAULT_MAX_STEPS = 5

  class WitException < Exception
  end

  class App
    getter logger
    getter actions

    def initialize(@access_token : String, @actions : Wit::Actions = NullActions.new, @logger : Logger = Logger.new(STDOUT).tap { |logger| logger.level = Logger::INFO })
    end

    def message(msg : String, msg_id : String? = nil, thread_id : String? = nil)
      logger.debug "Message request: msg='#{msg}'"
      params = { "q" => msg, "msg_id" => msg_id, "thread_id" => thread_id }
      res = request "GET", "/message", MessageResponse, params
      logger.debug "Message response: #{res.inspect}"
      return res.as(MessageResponse)
    end

    def converse(session_id : String, msg : String?, context : State? = nil)
      logger.debug "Converse request: session_id=#{session_id} msg='#{msg}' context=#{context}"
      res = request "POST", "/converse", ConverseResponse, {"q" => msg, "session_id" => session_id}, context.try(&.to_json)
      logger.debug "Converse response: #{res.inspect}"
      return res as ConverseResponse
    end

    def speech(data : Slice(UInt8), content_type : String, msg_id : String? = nil, thread_id : String? = nil)
      logger.debug "Speech request: type=#{content_type}"
      res = request "POST", "/speech", MessageResponse, { "msg_id" => msg_id, "thread_id" => thread_id }, String.new(data), content_type: content_type
      logger.debug "Speech response: #{res.inspect}"
      return res.as(MessageResponse)
    end

    protected def request(method, path, obj, params, payload = nil, content_type = "application/json")
      uri = URI.parse(WIT_API_HOST)
      uri.path = path
      uri.query = HTTP::Params.build do |q|
        params.each do |k,v|
          q.add(k, v) unless v.nil?
        end
      end if params

      headers = HTTP::Headers.new
      headers.add("authorization", "Bearer #{@access_token}")
      headers.add("accept", "application/vnd.wit.20160526+json")
      headers.add("Content-Type", content_type)

      response = HTTP::Client.exec(method, uri, headers, payload)
      raise WitException.new "HTTP error code=#{response.status_code}" unless response.success?

      begin
        return obj.from_json(response.body)
      rescue ex
        data = JSON.parse(response.body)
        raise WitException.new data["error"]? ? "Error in response: #{data["error"].as_s}\n#{response.body}" : "Error parsing response: #{ex.to_s}\n#{response.body}"
      end

    end

    def run_actions(session_id : String, message : String?, context : Wit::State? = nil, max_steps : Int32 = DEFAULT_MAX_STEPS, user_message : String? = nil)
      raise WitException.new "Max iterations reached" unless max_steps > 0

      user_message ||= message
      context ||= Wit::State.new

      begin
        response = converse session_id, message, context
      rescue ex : WitException
        logger.info "Execution error #{ex.to_s}"
        return @actions.error(session_id, context, ex, 1.0)
      end

      if response.type == "stop"
        return @actions.stop session_id, context.clone, response.confidence
      elsif response.type == "msg"
        msg = response.msg.not_nil!
        logger.info "Executing say with: #{msg} (#{response.confidence})"
        @actions.say session_id, context.clone, msg, response.confidence
      elsif response.type == "merge"
        entities = response.entities.not_nil!
        logger.info "Executing merge with #{entities.inspect} (#{response.confidence})"
        context = @actions.merge session_id, context.clone, entities, user_message, response.confidence
      elsif response.type == "action"
        action = response.action.not_nil!
        logger.info "Executing action #{action} (#{response.confidence})"
        context = @actions.custom action, session_id, context.clone, response.confidence
      elsif response.type == "error"
        logger.info "Executing error (#{response.confidence})"
        return @actions.error session_id, context.clone, WitException.new("Error in converse call"), response.confidence
      else
        raise WitException.new "Unknown converse type: #{response.type}"
      end

      logger.debug "Context is #{context.inspect}"
      return run_actions session_id, nil, context, max_steps - 1, user_message
    end

    def interactive(context : Wit::State? = nil, max_steps : Int32 = DEFAULT_MAX_STEPS)
      session_id = SecureRandom.uuid

      while true
        print "> "
        msg = gets.try(&.strip) || ""

        begin
          context = run_actions(session_id, msg, context, max_steps)
        rescue exp : WitException
          p exp.message
        end
      end
    end

  end
end
