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

    def message(msg : String, context : Context? = nil)
      logger.debug "Message request: msg='#{msg}' context=#{context.inspect}"
      params = {"q" => msg}
      params["context"] = context.to_json if context
      res = request "GET", "/message", MessageResponse, params
      logger.debug "Message response: #{res.inspect}"
      return res as MessageResponse
    end

    def converse(session_id : String, msg : String?, context : State? = nil)
      logger.debug "Converse request: session_id=#{session_id} msg='#{msg}' context=#{context}"
      res = request "POST", "/converse", ConverseResponse, {"q" => msg, "session_id" => session_id}, context
      logger.debug "Converse response: #{res.inspect}"
      return res as ConverseResponse
    end

    protected def request(method, path, obj, params, payload = nil)
      uri = URI.parse(WIT_API_HOST)
      uri.path = path
      uri.query = HTTP::Params.build do |q|
        params.each do |k,v|
          q.add(k, v) unless v.nil?
        end
      end if params

      headers = HTTP::Headers.new
      headers.add("authorization", "Bearer #{@access_token}")
      headers.add("accept", "application/vnd.wit.20160519+json")
      headers.add("Content-Type", "application/json")

      response = HTTP::Client.exec(method, uri, headers, payload.try(&.to_json))
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
        logger.info "Executing error #{ex.to_s}"
        return @actions.error(session_id, context, ex)
      end

      return context if response.type == "stop"
      if response.type == "msg"
        msg = response.msg.not_nil!
        logger.info "Executing say with: #{msg}"
        @actions.say session_id, context.clone, msg
      elsif response.type == "merge"
        entities = response.entities.not_nil!
        logger.info "Executing merge with #{entities.inspect}"
        context = @actions.merge session_id, context.clone, entities, user_message
      elsif response.type == "action"
        action = response.action.not_nil!
        logger.info "Executing action #{action}"
        context = @actions.custom action, session_id, context.clone
      elsif response.type == "error"
        logger.info "Executing error"
        return @actions.error session_id, context.clone, WitException.new("Error in converse call")
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
