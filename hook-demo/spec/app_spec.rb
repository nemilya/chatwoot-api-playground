# spec/app_spec.rb
require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require 'json'
require_relative '../app'

ENV['RACK_ENV'] = 'test'

RSpec.describe 'Sinatra Application' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  let(:openai_stub) { instance_double(OpenAI::Client) }

  before do
    WebMock.enable!

    # Stub the OpenAI Client initialization to return the stub
    allow(OpenAI::Client).to receive(:new).and_return(openai_stub)

    allow(openai_stub).to receive(:completions).with(parameters: {
        model: LLM_MODEL,
        prompt: 'Hi',
        max_tokens: 150
      }).and_return({
        'choices' => [{'text' => 'Hello, how can I help you?'}]
      })

    stub_request(:post, "#{CHATWOOT_DOMAIN}/api/v1/accounts/#{ACCOUNT_ID}/conversations/1/messages")
      .with(
        body: { content: "Hello, how can I help you?", message_type: 'outgoing', private: false }.to_json,
        headers: { 'Content-Type' => 'application/json', 'api_access_token' => API_ACCESS_TOKEN }
      ).to_return(status: 200, body: "", headers: {})
  end

  after do
    WebMock.disable!
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
        id: "1",
      },
      account: {
        id: "1",
        name: "Chatwoot"
      }
    }.to_json
  end

  it 'responds to the incoming message event and sends a message to the Chatwoot API' do
    post '/', incoming_request_payload, { "CONTENT_TYPE" => "application/json" }

    expect(last_response.status).to eq 200
    
    # Verify that the stubbed method was called with the correct parameters
    expect(openai_stub).to have_received(:completions).with(
      parameters: {
        model: LLM_MODEL,
        prompt: 'Hi',
        max_tokens: 150
      }
    ).once

    expect(WebMock).to have_requested(:post, "#{CHATWOOT_DOMAIN}/api/v1/accounts/#{ACCOUNT_ID}/conversations/1/messages")
      .with(
        body: { content: "Hello, how can I help you?", message_type: 'outgoing', private: false }.to_json,
        headers: { 'Content-Type' => 'application/json', 'api_access_token' => API_ACCESS_TOKEN }
      ).once
  end
end
