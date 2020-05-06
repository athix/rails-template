# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Factories
# require 'factory_bot_rails'
# require 'faker'

# Policy Specs
# require 'pundit/rspec'
# require 'pundit/matchers'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # Include Sorcery Spec Helpers
  config.include Sorcery::TestHelpers::Rails::Controller,  type: :controller
  config.include Sorcery::TestHelpers::Rails::Integration, type: :feature
  # Allow shortened FactoryBot syntax.
  # i.e. (create instead of FactoryBot.create)
  config.include FactoryBot::Syntax::Methods
  # Allow shortened I18n translation syntax.
  # i.e. (t('message') instead of I18n.t('message'))
  config.include AbstractController::Translation

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Use color in STDOUT and in pagers and files
  config.color = true
  config.tty = true

  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended.
  config.disable_monkey_patching!

  # Allow the use of the `--only-failures` flag when running rspec
  config.example_status_persistence_file_path =
    Rails.root.join('tmp', 'rspec', 'previous_failures.txt')

  # Find load order dependencies
  config.order = :random
  # Allow replicating load order dependency
  # by passing in same seed using --seed
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # These are the Setup and Takedown hooks
  # to ensure the database stays in sync
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation, reset_ids: true)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    Faker::UniqueGenerator.clear
    ActionMailer::Base.deliveries.clear
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
