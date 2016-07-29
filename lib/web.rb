require "sinatra"
require "json"
require "dotenv"
require "customerio"

Dotenv.load

def slack_url
  @slack_url ||= ENV["SLACK_WEBHOOK_URL"]
end

def customerio_environment
  @customerio_environment ||= ENV["ENVIRONMENT"]
end

def customerio_username
  @customerio_username ||= ENV["SLACK_USERNAME"]
end

def deliver_warnings(failed_customerio_campaign)
  message = "Failed to create email `#{failed_customerio_campaign}` in the \"#{customerio_environment}\" environment due to a template problem. Please check it out as others may be affected."
  params = {
    username: customerio_username,
    text: message
  }
  Net::HTTP.post_form(URI(slack_url), "payload" => params.to_json)
end

post "/" do
  begin
    parsed_params = JSON.parse(request.body.read.to_s)
    event_type = parsed_params["event_type"]

    if event_type == "email_failed"
      failed_customerio_campaign = parsed_params["data"]["campaign_name"]
      deliver_warnings(failed_customerio_campaign)
    end

    status 200
  rescue JSON::ParserError
    status 400
  end
end
