demo hook on conversation, and response from llm.

On Chatwoot: on account settings, Integrations - configure Webhooks - add record:
- url - `http://YOU_LOCAL_DOMAIN_NAME:4567`
- checkbox on - `Message created (message_created)`

setup on 5000 port `llm_api` (todo to direct openai api access)

configure `config.yml`
- `api_access_token` - take from user in account

start web server on same machine as chatwoot:
- `ruby app.rb`

Documentation:
* https://www.chatwoot.com/docs/product/features/webhooks
