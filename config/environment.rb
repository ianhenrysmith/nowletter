# Load the Rails application.
require File.expand_path('../application', __FILE__)

Rails.application.configure do
  config.log_level = :debug
end

# Initialize the Rails application.
Rails.application.initialize!
