require "json"

module Wit

  module Actions

    abstract def say(session_id : String, context : Wit::State, message : String)
    abstract def merge(session_id : String, context : Wit::State, entities : Hash(String, Array(JSON::Any)), msg : String?) : Wit::State
    abstract def error(session_id : String, context : Wit::State, error : WitException) : Wit::State
    abstract def custom(action_name : String, session_id : String, context : Wit::State) : Wit::State

  end

  class NullActions

    include Actions

    def say(session_id : String, context : Wit::State, message : String)
    end

    def merge(session_id : String, context : Wit::State, entities : Hash(String, Array(JSON::Any)), msg : String?) : Wit::State
      context
    end

    def error(session_id : String, context : Wit::State, error : WitException) : Wit::State
      context
    end

    def custom(action_name : String, session_id : String, context : Wit::State) : Wit::State
      context
    end

  end

end
