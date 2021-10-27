

DATABASE_URL = ENV["DATABASE_URL"]

::Log.builder.bind "clear.*", Log::Severity::Debug, Log::IOBackend.new
Clear::SQL.init(DATABASE_URL)



Clear.with_cli do
end
