require 'net/http'
require 'pry'

module HTTPServer

  DATA_STUFF = {"/users" => %w{random bits of junk that will be used}}
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
          http_res = HTTP.request(headers)
          client.write http_res.router
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
  end

  class HTTP

    def initialize(headers={})
      @route = headers['route'].gsub(/\/$/, '')
      # @route = headers['route'] == "/" ? "/index.html" : headers['route']
      @head  = headers
      @files = Dir["./root/**/*.html"]
      @dirs  = Dir.glob("./root/**/*")
    end

    def users
      users = USERS.map { |user| "<li><a href='/users/#{user}'>#{user}</a></li>" }.join('')
      contents = "<html><body><h1>USERS</h1><ul>#{users}</ul></body></html>"
    end

    def index_exists?
      @files.include?("./root#{@route}/index.html")
    end

    def router
      @root = File.dirname(@route)
      if @route.empty?
        render 200, File.read("./root/index.html"), "OK"
      elsif route_exists?
        if @route =~ /\.html$/
          render 200, File.read("./root#{@route}"), "OK"
        elsif index_exists?
          render 200, File.read("./root#{@route}/index.html"), "OK"
        else
          section = @route.gsub(/^.+(?=\/.+$)/, '')
          render 200, render_section(section), "OK"
        end
      else
        render 404, File.read("./root/not-found.html"), "NOT FOUND"
      end
    end

    def render_section(section)
      content = DATA_STUFF[section].map { |sec| "<li><a href='#{section}/#{sec}'>#{sec}</a></li>" }
      "<html><body><h1>#{section}</h1><ul>#{content.join('')}</ul></body></html>"
    end

    def to_http(len)
      "Content-Length: #{len}\r\nContent-Type: text/html\r\nConnection: Closed"
    end

    def render(code, body, http_msg)
      "#{code} HTTP/1.1 #{http_msg}\r\n#{to_http(body.size)}\r\n\n#{body}"
    end

    def route_exists?
      @dirs.include?("./root#{@route}") || @dirs.include?("./root#{}")
    end

    def self.request(headers)
      case headers['method']
      when 'GET'
        Get.new(headers)
      end
    end
  end

  class Get < HTTP
    def initialize(header={})
      super(header)
    end
  end
end

HTTPServer::Server.new.start
