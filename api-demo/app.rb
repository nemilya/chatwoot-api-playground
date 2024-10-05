require 'sinatra'
require 'httparty'
require 'dotenv/load'

API_DOMAIN = ENV['API_DOMAIN']
API_KEY = ENV['API_KEY']

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/*' do
  path = params['splat'].first
  query_params = request.query_string

  url = "#{API_DOMAIN}/#{path}?#{query_params}"

  response = HTTParty.get(url, headers: { 'api_access_token' => API_KEY })

  content_type :json
  status response.code
  body response.body
end
