require 'gnip-stream/stream_delegate'

module GnipStream
  class JsonStream
    include StreamDelegate
    def initialize(url, username, password, headers={})
      json_processor = GzippedJSONBuffer.new
      @stream = Stream.new(url, username, password, json_processor, headers)
    end
  end
end
