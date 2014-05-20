require 'net/http'
require 'pry'
module HTTPServer

  NOT_FOUND = "HTTP/1.1 404 NOT FOUND\r\n"

  class Server


    def index
      File.read("./root/index.html")
    end

    def http_ok
      "HTTP/1.1 200 OK\r\nContent-Length: 100\r\nContent-Type: text/html\r\nConnection: Closed\r\n\r\n<html>\n#{index}\n</html>\n\r\n"
    end

    def start
      Socket.tcp_server_loop(9393) do |client, sock|
        res = client.read(1000)
        d = Response.new res
        a = d.headers
        binding.pry

        client.write(http_ok)
        client.close
      end
    end

    class Response
      def initialize(data)
        @data = data
      end

      def raw_headers
        @data.split(/\r\n/)[0..-1]
      end

      def headers
        method, route, _ = raw_headers[0].split(/\s/)
        {method: route}.merge(set_headers)
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
    end
  end
end

HTTPServer::Server.new.start