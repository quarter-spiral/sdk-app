Bundler.require

require 'newrelic_rpm'
require 'new_relic/agent/instrumentation/rack'
require 'ping-middleware'

class NewRelicMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  end
  include NewRelic::Agent::Instrumentation::Rack
end

use NewRelicMiddleware
use Ping::Middleware

require 'raven'
require 'qs/request/tracker/raven_processor'
Raven.configure do |config|
  config.tags = {'app' => 'sdk-app'}
  config.processors = [Raven::Processor::SanitizeData, Qs::Request::Tracker::RavenProcessor]
end
use Raven::Rack
use Qs::Request::Tracker::Middleware

run Sdk::App::App.new