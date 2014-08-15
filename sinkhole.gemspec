# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinkhole/version'

Gem::Specification.new do |spec|
  spec.name          = "sinkhole"
  spec.version       = Sinkhole::VERSION
  spec.authors       = ["Andrew Stucki"]
  spec.email         = ["andrew.stucki@govdelivery.com"]
  spec.summary       = %q{Sinkhole is a simple smtp library with hooks}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry", "0.10.0"
  spec.add_development_dependency "rspec", "3.0.0"
  spec.add_development_dependency "simplecov", "0.9.0"
  spec.add_development_dependency "mocha", "1.1.0"

  spec.add_runtime_dependency "celluloid-io", "0.15.0"
  spec.add_runtime_dependency "hooks", "0.4.0"
end