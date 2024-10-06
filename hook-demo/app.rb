require 'sinatra'
require 'json'
require 'net/http'
require 'yaml'
require 'openai'

# Load configuration from YAML file
config = YAML.load_file('config.yml')

CHATWOOT_DOMAIN = config['chatwoot_domain']
API_ACCESS_TOKEN = config['api_access_token']
ACCOUNT_ID = config['account_id']
OPENAI_API_KEY = config['openai_api_key']
OPENAI_URI_BASE = config['openai_uri_base']
LLM_MODEL = config['llm_model']

helpers do
  def openai_client
    @openai_client ||= OpenAI::Client.new(
      uri_base: OPENAI_URI_BASE,
      access_token: OPENAI_API_KEY
    )
  end

  def llm_ask(text)
    begin
      response = openai_client.completions(
        parameters: {
          model: LLM_MODEL,
          prompt: text,
          max_tokens: 150
        }
      )
      response_text = response['choices'][0]['text'].strip
      response_text
    rescue OpenAI::Error => e
      puts "OpenAI-specific error: #{e.message}"
      'Error processing LLM response'
    rescue StandardError => e
      puts "General error in llm_ask: #{e.message}"
      puts e.backtrace.join("\n")
      'Error processing LLM response'
    end
  end
end

post '/' do
  begin
    body = request.body.read
    data = JSON.parse(body)

    if data['event'] == 'message_created' && data['message_type'] == 'incoming'
      conversation_id = data['conversation']['id']
      message = data['content']

      response_message = llm_ask(message)

      uri = URI("#{CHATWOOT_DOMAIN}/api/v1/accounts/#{ACCOUNT_ID}/conversations/#{conversation_id}/messages")
      header = { 'Content-Type': 'application/json', 'api_access_token': API_ACCESS_TOKEN }

      payload = {
        content: response_message,
        message_type: 'outgoing',
        private: false
      }

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Post.new(uri.path, header)
        request.body = payload.to_json
        http.request(request)
      end

      status response.code.to_i
      response.body
    else
      status 200
      body 'No action taken'
    end
  rescue JSON::ParserError => e
    puts "JSON Parse Error: #{e.message}"
    puts e.backtrace.join("\n")
    status 400
    body 'Invalid JSON request'
  rescue => e
    puts "Error processing request: #{e.message}"
    puts e.backtrace.join("\n")
    status 500
    body 'Internal server error'
  end
end
