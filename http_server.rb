require 'pry'
require 'net/http'
require 'rack'

module HttpServer
  class RequestController
    def call(env)
      route = Router.new(env)

      route.method_call

    end
  end

  class Router
    def initialize(env)
      @env = env
      @meth = env['REQUEST_METHOD']
      @path = env['REQUEST_PATH']
    end

    def method_call
      if @meth == "GET"
        get(@path) do

        end
      end
    end
  end

  class Response
    def res

    end
  end
end


Rack::Handler::WEBrick.run( HttpServer::RequestController.new, :Port => 9393 )
