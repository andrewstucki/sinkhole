require 'simplecov'
SimpleCov.start

$:.unshift File.join(File.expand_path(File.join(__FILE__,'..','..')), 'lib')
Dir["./spec/*/support/**/*.rb"].sort.each { |f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
end
