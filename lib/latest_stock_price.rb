module LatestStockPrice
  require 'net/http'
  require 'json'

  # BASE_URL = 'https://latest-stock-price.p.rapidapi.com/'
  BASE_URL = ENV.fetch('RAPIDAPI_BASE_URL', 'https://latest-stock-price.p.rapidapi.com')

  def self.price(stock_symbol)
    request("/price/#{stock_symbol}")
  end

  def self.prices(stock_symbols)
    request("/prices/#{stock_symbols.join(',')}")
  end

  def self.price_all
    request('any')
  end

  private

  def self.request(endpoint)
    uri = URI(BASE_URL + endpoint)
    req = Net::HTTP::Get.new(uri)
    req['X-RapidAPI-Key'] = ENV['RAPIDAPI_KEY']  # Add your API key in environment variables
    req['X-RapidAPI-Host'] = ENV.fetch('RAPIDAPI_HOST', 'latest-stock-price.p.rapidapi.com')

    p uri
    puts req['X-RapidAPI-Host']

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
    JSON.parse(response.body)
  end
end
