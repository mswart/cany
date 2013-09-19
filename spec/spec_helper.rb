require 'coveralls'
Coveralls.wear! do
  add_filter 'spec'
end

require 'cany'
require 'deb_control'
require 'tmpdir'
require 'timecop'

class TestRecipe < Cany::Recipe
  register_as :test_recipe
  hook :test_hook
end

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
    allow_any_instance_of(Cany::Recipe).to receive(:exec) { |*args| @executed_programs << args }
  end
end
