

module HTTPServer
  class Server
    class Route < Server
      def initialize(route)
        @route = route == "/" ? "/index.html" : route
      end

      def parse_route
        if route_defined?
          if index_exist?
            http_create(200, File.read("./root#{@route}/index.html"))
          else
            http_create(200, File.read("./root#{@route}"))
          end
        elsif File.directory? "./root#{@route}"
          extract_path
        else
          http_create(404, File.read("./root/not-found.html") + "#{@route} not found")
        end
      end

      def index_exist?
        File.file?("./root#{@route}/index.html")
      end

      def route_defined?
        File.file?("./root" + @route) || index_exist?
      end

      def extract_path
        base, action = File.split @route

        if respond_to? action.to_sym
          self.send action, base
        else
          http_create(200, "<h1>#{action}</h1>")
        end
      end

      def delete
        binding.pry
      end

      def show(base=nil)
        binding.pry
      end
    end
  end
end
