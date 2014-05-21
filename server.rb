require 'net/http'
require 'pry'




module HTTPServer

  USERS = %q{matt rose georgie something peace yall}
  NOT_FOUND = "HTTP/1.1 404 NOT FOUND\r\n"
  HTTP_OK = "HTTP/1.1 200 OK\r\n"

  class Server
    def initialize(port=9393)
      @port = port
    end

    def start
      server = TCPServer.new @port
      puts "listening on port " + @port.to_s
      loop do
        Thread.start(server.accept) do |client|
          request = client.read(300)

          headers = parse_headers(request)
          http_res = HTTPResponse.new(headers).create
          client.write http_res
          client.close
        end
      end
    end

    def parse_headers(res)
      raw_headers = res.split(/\r\n/)
      method, route, _ = raw_headers[0].split(/\s/)
      response_type = {'method' => method, 'route' => route }
      
      hash = {}
      raw_headers.each do |head|
        key = head[/[\w\-]+(?=\:)/]
        val = head[/(?<=\:\s).+(?=$)/]
        hash[key] = val
      end
      hash.merge(response_type)
    end


    class HTTPResponse
      def initialize(headers={})
        @route  = headers['route']
        if @route == '/' 
          @route = "/index.html"
        end
        @method = headers['method']
        # TODO handle multiple filetypes
        @root   = Dir["./root/**/*.html"]
      end

      def create
        if @root.include?("./root" + @route)
          case @method
          when 'GET' then do_get
          when 'POST' then do_post
          when 'UPDATE' then do_update
            # etc...
          end
        else
          do_404
        end
      end

      def do_404
        "HTTP/1.1 404 NOT FOUND\r\n"
      end

      def do_get
        response_message
      end

      def contents
        if @route == '/'
          File.read('./root/index.html')
        else
          File.read("./root#{@route}")
        end
      end

      def response_message
        "#{HTTP_OK}Content-Length: #{contents.length}"\
        "\r\nContent-Type: text/html\r\nConnection: Closed\r\n"\
          "\r\n#{contents}\n\r\n"
      end

      def main_header
        
      end

      def do_post

      end

      def do_update

      end
    end
  end
end

HTTPServer::Server.new.start
