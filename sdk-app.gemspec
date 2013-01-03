# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sdk-app/version'

Gem::Specification.new do |gem|
  gem.name          = "sdk-app"
  gem.version       = Sdk::App::VERSION
  gem.authors       = ["Thorben Schröder"]
  gem.email         = ["stillepost@gmail.com"]
  gem.description   = %q{This SDK is the interface between your game and the Quarter Spiral platform}
  gem.summary       = %q{This SDK is the interface between your game and the Quarter Spiral platform}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'sinatra', '~> 1.3.3'
  gem.add_dependency 'sinatra-assetpack', '~> 0.0.11'
  gem.add_dependency 'coffee-script', '~> 2.2.0'
  gem.add_dependency 'yui-compressor', '~> 0.9.6'
  gem.add_dependency 'therubyracer', '~> 0.10.0'
  gem.add_dependency 'newrelic_rpm', '~> 3.5.4.33'
  gem.add_dependency 'ping-middleware', '~> 0.0.2'
  gem.add_dependency 'json', '~> 1.7.5'
end