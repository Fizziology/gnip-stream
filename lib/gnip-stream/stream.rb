require 'eventmachine'
require 'net/http'

module GnipStream
  class Stream
    
    EventMachine.threadpool_size = 3

    attr_accessor :headers, :options, :url, :username, :password

    def initialize(url, username, password, processor, headers={})
      @url = URI.parse(url)
      @headers = headers
      @username = username
      @password = password
      @processor = processor
    end

    def on_message(&block)
      @on_message = block
    end

    def on_connection_close(&block)
      @on_connection_close = block
    end

    def on_error(&block)
      @on_error = block
    end

    def connect
      EM.run do
        Net::HTTP.start( url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
          begin
            request = Net::HTTP::Get.new url.request_uri
            request.initialize_http_header(headers)
            request.basic_auth @username, @password
            
            http.request(request) do |response|
              StringIO.open do |io|
                response.read_body{ |chunk| process_chunk( chunk ) }
              end
            end
            
            http.callback { 
              handle_connection_close(http) 
              EM.stop
            }
            http.errback { 
              handle_error(http)
              EM.stop
            }
          rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
            handle_error( http ) 
          end
        end
      end
    end

    def process_chunk(chunk)
      @processor.process(chunk)
      @processor.complete_entries.each do |entry|
        EM.defer { @on_message.call(entry) }
      end
    end

    def handle_error(http_connection)
      @on_error.call(http_connection)
    end

    def handle_connection_close(http_connection)
      @on_connection_close.call(http_connection)
    end

  end
end
