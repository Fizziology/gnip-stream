require 'gnip-stream/stream_delegate'

module GnipStream
  class JsonStream
    include StreamDelegate
    def initialize(url, username, password, headers={}, split_pattern = "\r\n")
      json_processor = JsonDataBuffer.new(split_pattern, Regexp.new(/^\{.*\}#{split_pattern}/))
      @stream = Stream.new(url, username, password, json_processor, headers)
    end
  end
end
