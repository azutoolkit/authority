# CSV Export Response
# Returns CSV content as plain text with appropriate headers
module Authority
  struct CsvResponse
    include Response

    def initialize(@content : String)
    end

    def render
      @content
    end
  end
end
