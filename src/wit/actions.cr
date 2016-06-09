require "json"

module Wit

  module Actions

    abstract def say(session_id : String, context : Wit::State, message : String, confidence : Float64)
    abstract def merge(session_id : String, context : Wit::State, entities : Hash(String, Array(JSON::Any)), msg : String?, confidence : Float64) : Wit::State
    abstract def error(session_id : String, context : Wit::State, error : WitException, confidence : Float64) : Wit::State
    abstract def custom(action_name : String, session_id : String, context : Wit::State, confidence : Float64) : Wit::State

    def stop(session_id : String, context : Wit::State, confidence : Float64) : Wit::State
      context
    end

  end

  class NullActions

    include Actions

    def say(session_id : String, context : Wit::State, message : String, confidence : Float64)
    end

    def merge(session_id : String, context : Wit::State, entities : Hash(String, Array(JSON::Any)), msg : String?, confidence : Float64) : Wit::State
      context
    end

    def error(session_id : String, context : Wit::State, error : WitException, confidence : Float64) : Wit::State
      context
    end

    def custom(action_name : String, session_id : String, context : Wit::State, confidence : Float64) : Wit::State
      context
    end

  end

end
