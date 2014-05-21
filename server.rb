require 'net/http'
require 'pry'
module HTTPServer
  USERS = %q{matt rose georgie something peace yall}
  NOT_FOUND = "HTTP/1.1 404 NOT FOUND\r\n"
  HTTP_OK = "HTTP/1.1 200 OK\r\n"
  class Server

    def start

      server = TCPServer.new 9393
      loop do
        Thread.start(server.accept) do |client|
          res = client.read(300)
          
          headers = parse_headers(res)
          http_res = HTTPResponse.new(client, headers)
          binding.pry
          http_res.respond
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
      def initialize(client, headers={})
        @client = client
        @route  = headers['route']
        @method = headers['method']
        @root   = Dir["./root/**/*.html"]
      end

      def respond
        @client.write(response)
      end

      def response
        if route?
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
        "\r\n<html>\n#{contents}\n</html>\n\r\n"
      end

      def main_header
        
      end

      def route?
        if @route == '/' || @route == '/index.html'
          File.exist?("./root/index.html")
        else
          @root.include?("./root" + @route)
        end
        # other routes...
      end

      def do_post
        
      end

      def do_update
        
      end
    end
  end
end

HTTPServer::Server.new.start