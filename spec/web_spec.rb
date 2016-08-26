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
      allow(ENV).to receive(:[]).with("SLACK_WEBHOOK_URL").and_return("www.slack.com")
      allow(ENV).to receive(:[]).with("ENVIRONMENT").and_return("production")
      allow(ENV).to receive(:[]).with("SLACK_USERNAME").and_return("Customerio Bot")
      allow(Net::HTTP).to receive(:post_form) { Net::HTTPSuccess.new(nil, nil, nil) }

      params = { event_type: "email_failed", data: { "campaign_name": "deposit_expired" } }
      post_as_json("/", params)

      expect(last_response.status).to eq(200)
      expect(Net::HTTP).to have_received(:post_form)
    end
  end
end
