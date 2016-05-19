require "json"

module Wit

  class Location

    JSON.mapping({
      latitude: Float64,
      longitude: Float64
    })

  end

end
