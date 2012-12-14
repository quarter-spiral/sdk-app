require 'sinatra'
require 'sinatra/assetpack'

module Sdk::App
  class App < Sinatra::Base
    set :root, File.expand_path('../../../assets', __FILE__)
    register Sinatra::AssetPack

    assets {
      serve '/javascripts',     from: 'javascripts'        # Optional

      # The second parameter defines where the compressed version will be served.
      # (Note: that parameter is optional, AssetPack will figure it out.)
      js :sdk, '/javascripts/sdk.js', [
        '/javascripts/vendor/*.js',
        '/javascripts/sdk/sdk.js'
      ]

      js_compression  :yui      # Optional
    }
  end
end