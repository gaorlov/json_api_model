
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "json_api_model/version"

Gem::Specification.new do |spec|
  spec.name          = "json_api_model"
  spec.version       = JsonApiModel::VERSION
  spec.authors       = ["Greg Orlov"]
  spec.email         = ["gaorlov@gmail.com"]

  spec.summary       = "Wrapper for JsonApiClient for in-app business logic."
  spec.homepage      = "http://github.com/gaorlov/json_api_model"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "json_api_client"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"
end
