if ENV['CI']
  require 'coveralls'
  Coveralls.wear! do
    add_filter 'spec'
  end
end

if ENV["COVERAGE"]
  require 'simplecov'

  SimpleCov.start do
    add_filter 'spec'

    add_group 'DPKG', 'lib/cany/dpkg'
    add_group('Recipes') { |file| file.filename.include? 'recipe' }
  end
end

require 'cany'
require 'deb_control'
require 'tmpdir'
require 'timecop'

class TestRecipe < Cany::Recipe
  register_as :test_recipe
  hook :test_hook
  option :test_conf
end

Cany.logger.level = Logger::FATAL


Dir[File.expand_path('spec/support/**/*.rb')].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.expect_with :rspec do |c|
    # Only allow expect syntax
    c.syntax = :expect
  end

  config.before(:each) do
    @executed_programs = []
    allow_any_instance_of(Cany::Recipe).to receive(:exec) { |*args| @executed_programs << args.flatten }
  end

  config.after(:each) do
    Cany::Recipes::Bundler::Gem.clear
    load 'cany/recipes/bundler/gem_db.rb'
  end
end
