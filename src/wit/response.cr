require "json"

module Wit

  class MessageResponse
    JSON.mapping({
      msg_id: String,
      _text: String,
      entities: Hash(String, Array(JSON::Any))
    })
  end

  class ConverseResponse
    JSON.mapping({
      type: String,
      confidence: Float64,
      msg: { type: String, nilable: true },
      action: { type: String, nilable: true },
      entities: { type: Hash(String, Array(JSON::Any)), nilable: true },
    })
  end

end
