require "clear"
require "./db/migrations/**"
require "./src/config/clear"
require "azu_cli"

Clear::SQL.init(DATABASE_URL)

AzuCLI.run
