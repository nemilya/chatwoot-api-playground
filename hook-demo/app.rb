require 'sinatra'
require 'json'
require 'net/http'
require 'uri'
require 'yaml'

# Load configuration from YAML file
config = YAML.load_file('config.yml')

CHATWOOT_DOMAIN = config['chatwoot_domain']
API_ACCESS_TOKEN = config['api_access_token']
ACCOUNT_ID = config['account_id']
LLM_API_URL = config['llm_api_url']
LLM_MODEL = config['llm_model']

helpers do
  def llm_ask(text)
    uri = URI(LLM_API_URL)
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')

    data = {
      prompt: text,
      model: LLM_MODEL
    }.to_json

    request.body = data

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    response_data = JSON.parse(response.body)
    response_data["response"]
  rescue JSON::ParserError
    'Error processing LLM response'
  end
end

post '/' do
  begin
    body = request.body.read
    data = JSON.parse(body) rescue {}

    if data['event'] == 'message_created' && data['message_type'] == 'incoming'
      conversation_id = data['conversation']['id']
      response_content = data['content']

      uri = URI("#{CHATWOOT_DOMAIN}/api/v1/accounts/#{ACCOUNT_ID}/conversations/#{conversation_id}/messages")
      header = { 'Content-Type': 'application/json', 'api_access_token': API_ACCESS_TOKEN }

      payload = {
        content: llm_ask(response_content),
        message_type: 'outgoing',
        private: false
      }

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Post.new(uri.path, header)
        request.body = payload.to_json
        http.request(request)
      end

      puts payload
      puts response.body
      status response.code.to_i
      response.body
    else
      status 200
      body 'No action taken'
    end
  rescue => e
    puts "Error processing request: #{e.message}"
    # puts e.backtrace
    status 500
    body 'Internal server error'
  end
end
