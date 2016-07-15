require "sinatra"
require "json"
require "dotenv"
require "customerio"

Dotenv.load

def deliver_warnings
  mailing_ids.each do |id|
    customerio_client.track(id, "mail_delivery_failed")
  end
end

def customerio_client
  @client ||= Customerio::Client.new(ENV["CUSTOMER_IO_SITE_ID"], ENV["CUSTOMER_IO_API_KEY"])
end

def mailing_ids
  @mailing_ids ||= ENV["CUSTOMER_IO_CLIENT_IDS"].split(" ").map(&:to_i)
end

post "/" do
  begin
    parsed_params = JSON.parse(request.body.read.to_s)
    event_type = parsed_params["event_type"]

    deliver_warnings if event_type == "email_failed"

    status 200
  rescue JSON::ParserError
    status 400
  end
end
