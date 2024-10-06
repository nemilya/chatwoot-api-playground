# Chatwoot LLM Integration

This application integrates Chatwoot with OpenAI's Language Model (LLM) to automatically respond to incoming messages in a conversation. It leverages webhooks provided by Chatwoot to trigger responses via OpenAI's API.

## Overview

The application listens for message events from Chatwoot and generates responses using a specified LLM model. Upon receiving a message, it uses the OpenAI API to generate a reply and responds within the same Chatwoot conversation.

## Setup Instructions

> On same server where Chatwoot installed

### 1. Install Dependencies

Navigate to the application's root directory and run the following command to install the necessary gems:

```bash
bundle install
```

### 2. Configure Webhook in Chatwoot

1. Navigate to your Chatwoot account settings.
2. Go to **Integrations** > **Webhooks**.
3. Add a new webhook with the following details:
    - **URL**: `http://YOUR_LOCAL_DOMAIN_NAME:4567` (replace `YOUR_LOCAL_DOMAIN_NAME` with your machine's domain name)
4. Enable the option: **Message created (message_created)**.

### 3. Configure `config.yml`

Create a `config.yml` file in the root directory of the application, based on `config.yml.template`. Fill in the required values:- `chatwoot_domain`: Your Chatwoot domain. Example: `https://your-chatwoot-domain.com`.
- `api_access_token`: Your Chatwoot API access token.
- `account_id`: Your Chatwoot account ID.
- `openai_api_key`: Your OpenAI API key.
- `openai_uri_base`: Typically, this is `https://api.openai.com/`.
- `llm_model`: The language model to use (e.g., `gpt-4o-mini`).

### 4. Start the Web Server

Start the server with the following command:

```bash
ruby app.rb -o YOUR_LOCAL_DOMAIN_NAME
```

Replace `YOUR_LOCAL_DOMAIN_NAME` with your actual domain name that can receive webhooks from Chatwoot.

### 5. Run Tests

To run the tests for this application, execute:

```bash
bundle exec rspec spec/app_spec.rb
```

## Documentation

- For more detailed information about setting up webhooks in Chatwoot, refer to the [Chatwoot Webhooks Documentation](https://www.chatwoot.com/docs/product/features/webhooks).
