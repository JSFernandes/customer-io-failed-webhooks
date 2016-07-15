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
    it "responds with JSON" do
      params = { event_type: "email_failed" }
      post_as_json("/", params)
      response_body = JSON.parse(last_response.body)
      expect(last_response.status).to eq(200)
      expect(response_body).to eq("notified" => "true")
    end
  end
end
