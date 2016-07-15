require "./lib/web.rb"
require "spec_helper.rb"

describe "the sinatra app" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def post_as_json(path, params)
    post path, params.to_json, "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json"
  end

  before do
    allow_any_instance_of(Customerio::Client).to receive(:track)
  end

  it "says hello world" do
    get "/"
    expect(last_response.body).to eq("Hello, world")
  end

  context "when receiving a POST without JSON" do
    it "responds with status ok" do
      post "/", event_type: "email_drafted"
      expect(last_response.status).to eq(400)
    end
  end

  context "when receiving a POST with JSON with event_type different from email_failed" do
    it "responds with status ok" do
      params = { event_type: "email_drafted" }
      post_as_json("/", params)
      expect(last_response.status).to eq(200)
    end
  end

  context "when receiving a POST with event_type email_failed" do
    it "delivers the warnings and responds with status ok" do
      allow(ENV).to receive(:[]).with("CUSTOMER_IO_CLIENT_IDS").and_return("1")
      allow(ENV).to receive(:[]).with("CUSTOMER_IO_SITE_ID").and_return("1")
      allow(ENV).to receive(:[]).with("CUSTOMER_IO_API_KEY").and_return("1")

      expect_any_instance_of(Customerio::Client).to receive(:track)
      params = { event_type: "email_failed" }
      post_as_json("/", params)

      expect(last_response.status).to eq(200)
    end
  end
end
