require "sinatra"
require "json"

get "/" do
  "Hello, world"
end

post "/" do
  begin
    parsed_params = JSON.parse(request.body.read.to_s)
    event_type = parsed_params["event_type"]
    if event_type == "email_failed"
      { notified: "true" }.to_json
    else
      status 200
    end
  rescue JSON::ParserError
    status 400
  end
end
