require 'net/http'
require 'pry'
module HTTPServer

  NOT_FOUND = "HTTP/1.1 404 NOT FOUND\r\n"

  class Server

    def start

      server = TCPServer.new 9393
      loop do
        Thread.start(server.accept) do |client|
          res = client.read(300)
          http_res = HTTPResponse.new(res, client)
          http_res.respond
          client.close
        end
      end
      # Socket.tcp_server_loop(9393) do |client, sock|
      #   begin
      #     res = client.read(1000)
      #     if res
      #       http_res = HTTPResponse.new(res, client)

      #       http_res.respond
      #     end
      #   ensure
      #     client.close
      #   end
      # end
    end

    class HTTPResponse
      def initialize(data, client)
        @data   = data
        @client = client
        @root   = Dir["./root/**/*.html"]
      end

      def raw_headers
        @data.split(/\r\n/)
      end

      def headers
        method, route, _ = raw_headers[0].split(/\s/)
        {'method' => method, 'route' => route }.merge(set_headers)
      end

      def set_headers
        hash = {}
        raw_headers.each do |head|
          key = head[/[\w\-]+(?=\:)/]
          val = head[/(?<=\:\s).+(?=$)/]
          hash[key] = val
        end
        hash
      end

      def respond
        @client.write(response)
      end

      def response
        if route?
          case headers['method']
          when 'GET' then do_get
          when 'POST' then do_post
          when 'UPDATE' then do_update
            # etc...
          end
        else
          NOT_FOUND
        end
      end

      def do_get
        response_message
      end

      def contents
        if headers['route'] == '/'
          File.read('./root/index.html')
        else
          File.read("./root#{headers['route']}")
        end
      end

      def response_message
        "HTTP/1.1 200 OK\r\nContent-Length: #{contents.length}"\
        "\r\nContent-Type: text/html\r\nConnection: Closed\r\n"\
        "\r\n<html>\n#{contents}\n</html>\n\r\n"
      end

      def route?
        if headers['route'] == '/' || headers['route'] == '/index.html'
          File.exist?("./root/index.html")
        else
          @root.include?("./root" + headers['route'])
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