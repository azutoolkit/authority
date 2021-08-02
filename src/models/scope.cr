# Model Docs - https://clear.gitbook.io/project/model/column-types
module Authority
  class Scope
    include Clear::Model
    self.table = "scopes"

    primary_key
    column scope : String
    column is_default : Bool

    timestamps
  end
end
