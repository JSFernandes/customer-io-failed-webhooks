require "sinatra"
require "json"
require "dotenv"
require "customerio"

Dotenv.load

def deliver_warnings(failed_customerio_campaign)
  mailing_ids.each do |id|
    customerio_client.track(id, "mail_delivery_failed", :failed_customerio_campaign => failed_customerio_campaign)
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

    if event_type == "email_failed"
      failed_customerio_campaign = parsed_params["data"]["campaign_name"]
      deliver_warnings(failed_customerio_campaign)
    end

    status 200
  rescue JSON::ParserError
    status 400
  end
end
