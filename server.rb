require 'net/http'
require 'pry'




module HTTPServer

  USERS = %q{matt rose georgie something peace yall}
  NOT_FOUND = "HTTP/1.1 404 NOT FOUND\r\n"
  HTTP_OK = "HTTP/1.1 200 OK\r\n"

  class Server
    def initialize(port=9393, routes={})
      @port = port
      @routes = routes
    end

    def start
      server = TCPServer.new @port
      puts "listening on port " + @port.to_s
      loop do
        Thread.start(server.accept) do |client|
          request = client.read(300)

          headers = parse_headers(request)
          code, content = get_content(headers)
          http_res = http_create(code, content)
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

    def get_content(headers)
      name = headers['route']
      #binding.pry
      if @routes.include? name
        return routes[name]
      else
        #binding.pry
        filename = './root' + name
        if File.file? filename
          return 200, (File.read filename)
        elsif File.exists? filename and File.file? (filename + "/index.html") 
          return 200, (File.read filename + "/index.html")
        else
          return 404, (File.read "./root/not-found.html")
        end
      end
    end

    def http_create(code, content)
      code_header = make_code_header(code)
      #binding.pry
      "#{code_header}Content-Length: #{content.length}"\
      "\r\nContent-Type: text/html\r\nConnection: Closed\r\n"\
      "\r\n#{content}\n\r\n"
    end

    def make_code_header(code)
      str = "HTTP/1.1 " + code.to_s
      if code == 200
        str += " OK"
      elsif code == 404
        str += " NOT FOUND"
      end
      str += "\r\n"
    end
  end
end

HTTPServer::Server.new.start
