require "./spec_helper"

describe Wit do

  it "should parse a context" do
    context = Wit::Context.from_json <<-JSON
    {
      "state": [
        "yes_or_no",
        "cancel"
      ],
      "reference_time": "2013-05-01T19:05:00-03:00",
      "timezone": "America/Los_Angeles",
      "entities": [
        {
          "id": "room",
          "values": [
            {
              "value": "bedroom",
              "expressions": [
                "bedroom",
                "bedchamber",
                "guest room"
              ]
            },
            {
              "value": "living room",
              "expressions": [
                "living room",
                "salon",
                "sitting room"
              ]
            }
          ]
        }
      ]
    }
    JSON

    context.state.should eq(["yes_or_no", "cancel"])
    context.reference_time.should eq(Time.parse("2013-05-01T19:05:00-03:00", "%FT%T%:z"))
    context.timezone.should eq("America/Los_Angeles")
    context.entities.size.should eq(1)

    entity = context.entities.first
    entity.id.should eq("room")
    entity.values.size.should eq(2)

    value = entity.values.first
    value.value.should eq("bedroom")
    value.expressions.should eq(["bedroom", "bedchamber", "guest room"])
  end

end
