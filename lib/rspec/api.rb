require "rspec/api/version"
require "rspec/api/api_example_group"
require "active_support/core_ext/array/extract_options"

class << self
  def resource(*args, &block)
    options = args.extract_options!
    options[:api] = true
    args.push(options)
    describe(*args, &block)
  end
end

RSpec.configure do |config|
  def config.escaped_path(*parts)
    Regexp.compile(parts.join('[\\\/]'))
  end

  config.include RSpec::Api::ApiExampleGroup, :type => :api, :example_group => {
    :file_path => config.escaped_path(%w[spec api])
  }
end

