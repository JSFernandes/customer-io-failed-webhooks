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

def deliver_warnings(parsed_customer_io_params)
  failed_customerio_campaign = parsed_customer_io_params["data"]["campaign_name"]
  message = "Failed to create email `#{failed_customerio_campaign}` in the \"#{customerio_environment}\"" \
            " environment due to a template problem. Please check it out as others may be affected."

  slack_params = {
    username: customerio_username,
    text: message,
    attachments: [{ title: "Snippet", mrkdown_in: ["text"], text: JSON.pretty_generate(parsed_customer_io_params) }]
  }
  Net::HTTP.post_form(URI(slack_url), "payload" => slack_params.to_json)
end

post "/" do
  begin
    parsed_params = JSON.parse(request.body.read.to_s)
    event_type = parsed_params["event_type"]
    deliver_warnings(parsed_params) if event_type == "email_failed"
    status 200
  rescue JSON::ParserError
    status 400
  end
end
