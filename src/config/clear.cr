# Clear Orm Docs - https://clear.gitbook.io/project/introduction/installation
DATABASE_URL = ENV["DATABASE_URL"]

Clear::SQL.init(DATABASE_URL)
