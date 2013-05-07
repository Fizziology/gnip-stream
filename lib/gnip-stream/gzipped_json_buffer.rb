require 'yajl'
module GnipStream
  class GzippedJSONBuffer

    SAFE_LINE =  /.+\r\n/
    END_OF_CHUNK = /\r\n\z/

    def initialize
      @decompressor = Zlib::Inflate.new( 16 + Zlib::MAX_WBITS )
      @decompressed = ''
    end

    def process(chunk)
      @decompressed << @decompressor.inflate(chunk).encode!( 'UTF-8', :invalid => :replace, :undef => :replace, :replace => 'xUx', :fallback => 'xUfx' )
    end

    def complete_entries
      entries = []

      if (!(@decompressed =~ END_OF_CHUNK).nil? and @decompressed.strip.present?)
        while (match_data = @decompressed.slice!(SAFE_LINE))
          entries << match_data
        end
      end

      entries
    end
  end
end
