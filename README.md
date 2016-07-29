# customer-io-failed-webhooks

## What is this?

Don't you hate how you may have errors in your Customerio templates, thus failing mail creation, and you have no way to know about it other than manually checking?
This app receives `email_failed` events from customerio and notifies a slack channel.

For more information on customerio webhooks check its documentation: https://customer.io/docs/webhooks.html

## Installing

Assuming you have ruby installed, installing this app shouldn't take more than a `bundle install`

## Developing

Code, open pull requests, do whatever you want, just remember to keep `bundle exec rspec` and `bundle exec rubocop` green.

## Running locally and deploying

To run this app you must populate the environment variables accordingly. A `.env` file in the project root will do for local development.
The required variables are as follows:

  - `SLACK_WEBHOOK_URL`: The webhook URL for your message's channel. See this page to get one: https://my.slack.com/services/new/incoming-webhook/
  - `ENVIRONMENT`: Environment from which your customerio is sending events.
  - `SLACK_USERNAME`: Username that you wish to associate to the slack notification.

After you have the environment variabls up, use the following command to run locally:

`bundle exec rackup -p [PORT] config.ru`

Remember to replace `[PORT]` by whichever port you wish to use.

Use whatever you want for deploying. I like heroku.

## Hooking up to customerio

Go to this page and add the app's URL: https://fly.customer.io/account/webhooks/edit
