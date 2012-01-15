# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rspec/api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paweł Pacana"]
  gem.email         = ["pawel.pacana@gmail.com"]
  gem.description   = %q{RSpec DSL for API testing.}
  gem.summary       = %q{DSL for testing API's derived from rspec_api_documentation project.}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rspec-api"
  gem.require_paths = ["lib"]
  gem.version       = Rspec::Api::VERSION

  gem.add_dependency "rspec", "~> 2.0"
  gem.add_dependency "activesupport", "~> 3.0"
end
