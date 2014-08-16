require 'simplecov'
SimpleCov.start

ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'capybara'
require 'capybara/rspec'
require 'rack/test'
require 'database_cleaner'
require_relative '../app'

set :views => File.join(File.dirname(__FILE__), "..", "views")

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
ActiveRecord::Base.logger.level = 1

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # this should give us Rack test methods
  #config.include Rack::Test::Methods
  config.include Capybara::DSL 

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end

Capybara.app = Sinatra::Application.new

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers =>  { 'User-Agent' => 'Capybara' })
end

# lets us use the Rack::Test MockRequests
def app
	Sinatra::Application.new
end
