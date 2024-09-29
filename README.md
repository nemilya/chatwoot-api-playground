# Chatwoot API Playground

A demo application to explore and interact with the Chatwoot API.
(work in progress)

## Features

This application provides an interface to interact with the Chatwoot API, allowing you to:
- List all contacts
- Access detailed information through card views

## Configuration

Before running the application, configure your environment variables in a `.env` file (copy from `.env.template`):

- `API_DOMAIN`: The URL of your Chatwoot instance
- `API_KEY`: Your Chatwoot API Key

Example `.env` file:

```
API_DOMAIN=https://app.chatwoot.com
API_KEY=your_api_key_here
```

## Installation

Follow these steps to install and set up the application:

1. **Install Ruby**: Use a version manager like `rbenv` to install Ruby.
2. **Install Dependencies**: Run `bundle install` to install the necessary gems.
3. **Run the Application**: Use `ruby app.rb` to start the application.

## Usage

Once the application is running, open your web browser and navigate to the following URL to start exploring:

- [http://localhost:4567/contacts.html](http://localhost:4567/contacts.html)

Enter `AccountId` and fetch list.
