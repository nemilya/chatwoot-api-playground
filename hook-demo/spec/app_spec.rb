# spec/app_spec.rb

require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require_relative '../app'  # Require your main application file

ENV['RACK_ENV'] = 'test'

RSpec.describe 'Sinatra Application' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before do
    WebMock.enable!  # Enable WebMock to intercept HTTP calls
    stub_request(:post, LLM_API_URL).to_return(
      body: { response: "Hello, how can I help you?" }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  after do
    WebMock.disable!  # Disable WebMock to avoid affecting other tests
  end

  let(:incoming_request_payload) do
    {
      event: "message_created",
      id: "1",
      content: "Hi",
      created_at: "2020-03-03 13:05:57 UTC",
      message_type: "incoming",
      content_type: "enum",
      content_attributes: {},
      source_id: "",
      sender: {
        id: "1",
        name: "Agent",
        email: "agent@example.com"
      },
      contact: {
        id: "1",
        name: "contact-name"
      },
      conversation: {
        id: "1",  # Ensure conversation_id is included and matches the expected ID
      },
      account: {
        id: "1",
        name: "Chatwoot"
      }
    }.to_json
  end

  it 'responds to the incoming message event and sends a message to the Chatwoot API' do
    stub_request(:post, "#{CHATWOOT_DOMAIN}/api/v1/accounts/#{ACCOUNT_ID}/conversations/1/messages")
      .with(
        body: { content: "Hello, how can I help you?", message_type: 'outgoing', private: false }.to_json,
        headers: { 'Content-Type' => 'application/json', 'api_access_token' => API_ACCESS_TOKEN }
      ).to_return(status: 200, body: "", headers: {})

    post '/', incoming_request_payload, { "CONTENT_TYPE" => "application/json" }

    puts "Response status: #{last_response.status}"
    puts "Response body: #{last_response.body}"

    expect(last_response.status).to eq 200
    expect(WebMock).to have_requested(:post, LLM_API_URL)
    expect(WebMock).to have_requested(:post, "#{CHATWOOT_DOMAIN}/api/v1/accounts/#{ACCOUNT_ID}/conversations/1/messages")
      .with(
        body: { content: "Hello, how can I help you?", message_type: 'outgoing', private: false }.to_json,
        headers: { 'Content-Type' => 'application/json', 'api_access_token' => API_ACCESS_TOKEN }
      )
  end
end

