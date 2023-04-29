# frozen_string_literal: true

class API < Hanami::API
  post '/addresses' do
    App['addresses.create'].call(params)
  end

  delete '/addresses/:address' do
    App['addresses.destroy'].call(params)
  end

  get '/stats/:address' do
    App['stats.index'].call(params)
  end
end
