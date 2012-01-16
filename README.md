ABOUT
-----

Derived from `https://github.com/zipmark/rspec_api_documentation` to
remove Rails dependency and downgrade to API testing DSL only.

Not sure how will this work out, but for now this is **all I need** for now.

INSTALL
-------

In `Gemfile`:

```ruby
gem 'rspec-api', :git => 'git://github.com/pawelpacana/rspec-api.git'
```

In `spec_helper.rb`:

```ruby
require 'rspec-api'
```

TODO
----

* add examples, for now have a look at: `https://github.com/zipmark/rspec_api_documentation/blob/master/example/spec/acceptance/orders_spec.rb`
* add note about test client dependency injection
* add copyrights and license
* add tests from derived project
* profit!
