source 'https://rubygems.org'

# Specify your gem's dependencies in cany.gemspec
gemspec

group :development do
  gem 'yard', '~> 0.8.6'
  gem 'guard'
  gem 'libnotify', :require => false
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
  gem 'guard-rspec'
  gem 'guard-yard'
  gem 'redcarpet', platform: :ruby
end

group :test do
  gem 'deb_control', '~> 0.0.1'
  gem 'coveralls', require: false
  gem 'timecop'
end
