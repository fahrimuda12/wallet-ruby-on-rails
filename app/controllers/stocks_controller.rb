class StocksController < ApplicationController
  include ResponseHelper

  require 'latest_stock_price'

  def price_all
    @stocks = LatestStockPrice.price_all
    if @stocks.empty?
      return error_response(message: 'No stocks found', errors: [], status: :not_found)
    end

    success_response(message: 'Success', data: @stocks)

    render json: data
  end

  def price
    @stock = LatestStockPrice.price(params_stocks[:id])
    if @stock.nil?
      return error_response(message: 'Stock not found', errors: [], status: :not_found)
    end

    success_response(message: 'Success', data: @stock)
  end

  def prices
    puts params_stocks[:stock_id]
    @stocks = LatestStockPrice.prices(params_stocks[:stock_id])
    if @stocks.empty?
      return error_response(message: 'Stocks not found', errors: [], status: :not_found)
    end

    success_response(message: 'Success', data: @stocks)
  end

  private

  def params_stocks
    params.permit(:id, :stock_id)
  end

end