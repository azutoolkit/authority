require "pg"
require "cql"
require "crypto/bcrypt/password"

# Enable SQL query logging
CQL.configure do |config|
  config.env = ENV["CRYSTAL_ENV"]? || "development"
  config.log_level = :debug
  config.sql_logging = true
  config.sql_logging_colorize = true
  config.sql_logging_async = false
end

# Initialize SQL logging using Performance module
CQL::Performance.enable_sql_logging(colorize: true, pretty: true)

# Load database schema
require "../db/schema"
