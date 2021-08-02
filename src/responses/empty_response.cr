module Authority
  class EmptyResponse
    include Azu::Response

    def render; end
  end
end
