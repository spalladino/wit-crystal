require "json"

module Wit
  class Context

    class Entity

      class Value
        JSON.mapping({
          value: String,
          expressions: Array(String)
        })
      end

      JSON.mapping({
        id: String,
        values: Array(Value)
      })
    end

    class StringOrArrayConverter
      def self.from_json(pull : JSON::PullParser)
        if pull.kind == :string
          [String.new(pull)]
        else
          Array(String).new(pull)
        end
      end

      def self.to_json(value, io)
        value.to_json(io)
      end
    end

    JSON.mapping({
      state: { type: Array(String), converter: StringOrArrayConverter, default: Array(String).new },
      reference_time: { type: Time, converter: Time::Format.new("%FT%T%:z"), nilable: true },
      timezone: { type: String, nilable: true },
      entities: { type: Array(Entity), default: Array(Entity).new },
      location: { type: Wit::Location, nilable: true }
    })

    def initialize(@state = Array(String).new, @reference_time = nil, @timezone = nil, @entities = Array(Entity).new, @location = nil)
    end

  end
end
