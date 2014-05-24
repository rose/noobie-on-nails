

module HTTPServer
  class Server
    class Route < Server
      def initialize(route)
        @route = route == "/" ? "/index.html" : route
        @files = Dir.glob("*/**/*")
      end

      def parse_route
        if route_defined?
          if index_exist?
            http_create(200, File.read("./root#{@route}/index.html"))
          elsif file_exist?
            http_create(200, File.read("./root#{@route}"))
          else
            not_found
          end
        else
          extract_path
        end
      end

      def base_route
        @route[/^.+?[^\/:](?=[?\/]|$)/]
      end

      def route_exists?
        @files.include?("root#{base_route}")
      end

      def file_exist?
        File.file?("./root#{@route}")
      end

      def index_exist?
        File.file?("./root#{@route}/index.html")
      end

      def route_defined?
        File.file?("./root" + @route) || index_exist?
      end

      def extract_path
        @base, *@action = @route.scan(/(\/\w+(?=\/)|\w+$)/).flatten

        case @action.length
        when 1
          # for now, returns itself
          http_create(200, "<h1>#{@action.first}</h1>")
        when 2
          if respond_to? @action.last
            self.send @action.last
          else
            not_found
          end
        else
          not_found
        end
      end

      def edit
        http_create 200, "<h1>Edit for #{@action.first}</h1>"
      end

      def target
        @base[/\w+$/]
      end

      def update
        http_create 404, File.read("./root/not-found.html") + "<h1>update not implemented</h1>"
      end

      def delete
        http_create 404, File.read("./root/not-found.html") + "<h1>delete not implemented</h1>"
      end

      def show
        http_create 404, File.read("./root/not-found.html") + "<h1>show not implemented</h1>"
      end
    end
  end
end
