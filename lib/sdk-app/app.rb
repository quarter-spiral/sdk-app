require 'sinatra'
require 'sinatra/assetpack'
require 'json'

module Sdk::App
  class App < Sinatra::Base
    set :root, File.expand_path('../../../assets', __FILE__)
    register Sinatra::AssetPack

    ENV_KEYS = ['QS_CANVAS_APP_URL']

    assets {
      serve '/javascripts',     from: 'javascripts'        # Optional

      # The second parameter defines where the compressed version will be served.
      # (Note: that parameter is optional, AssetPack will figure it out.)
      js :sdk, '/javascripts/sdk.js', [
        '/javascripts/vendor/*.js',
        '/javascripts/sdk/envs.js',
        '/javascripts/sdk/sdk.js'
      ]

      js_compression  :yui      # Optional
    }

    # Environment variables
    get '/javascripts/sdk/envs.js' do
      env = {"ENV" => Hash[ENV_KEYS.map {|k| [k, ENV[k]]}]}

      "window.qsSdk = #{JSON.dump(env)};"
    end
  end
end