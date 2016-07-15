require "./lib/web.rb"
require "spec_helper.rb"

describe "the sinatra app" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "says hello world" do
    get "/"
    expect(last_response.body).to eq("Hello, world")
  end
end
