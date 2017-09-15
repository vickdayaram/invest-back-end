require 'rest_client'
require 'json'

class Holding < ApplicationRecord
  has_many :transactions

  def get_price(symbol)
    url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=#{symbol}&interval=1min&outputsize=compact&apikey=NKIEQH9ZHQ1ZFJVL"
    response = RestClient.get(url)
    json = JSON.parse(response)
    price = json["Time Series (Daily)"].first[1]["1. open"]
    return price
  end

end
