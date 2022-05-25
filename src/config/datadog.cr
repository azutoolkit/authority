# require "datadog/integrations"
# require "datadog/integrations/db"

# module Datadog::Integrations
#   class Azu
#     include Integration

#     def initialize(@name : String)
#       @service = Service.new(@name, type: "web")
#     end

#     # Returns a configuration that will report every different domain as a separate service
#     def self.split_by_domain
#       new
#     end

#     def register(integrations)
#       integrations[%w(azu)] = self
#     end

#     def trace(name, resource, tags = Span::Metadata.new)
#       Datadog.tracer.trace name, service: @service, resource: resource, tags: tags do |span|
#         yield span
#       end
#     end
#   end
# end

# Datadog.configure do |c|
#   # Define your service
#   c.service ENV["DD_SERVICE"], type: "web"
#   c.tracing_enabled = ENV["DD_TRACING_ENABLED"] == "true"

#   # Define tags you want on every span
#   c.tags = Datadog::Span::Metadata{
#     "env"     => ENV["DD_ENV"],
#     "version" => ENV["DD_VERSION"],
#   }
#   c.use Datadog::Integrations::Azu.new "authority"
#   c.use Datadog::Integrations::DB.new "authority_db", "localhost", "authority_db"
# end
