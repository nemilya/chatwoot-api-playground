demo hook on conversation, and response from llm.

On Chatwoot: on account settings, Integrations - configure Webhooks - add record:
- url - `http://YOU_LOCAL_DOMAIN_NAME:4567`
- checkbox on - `Message created (message_created)`

configure `config.yml` (based on `config.yml.template`):
- `api_access_token` - take from user in account
- `account_id` - your account id
- `openai_api_key` - your openai api key

start web server on same machine as chatwoot:
- `ruby app.rb -o YOU_LOCAL_DOMAIN_NAME`

tests:
- `bundle exec rspec spec/app_spec.rb`

Documentation:
* https://www.chatwoot.com/docs/product/features/webhooks
