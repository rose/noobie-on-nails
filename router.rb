class Router
  def initialize
    @routes = []
  end

  def add_route(regex, function)
    @routes.push([regex, function])
  end

  def process(url)
    for route, f in @routes
      m = route.match(url)
      if m 
        args = {}
        for name in m.names
          args[name] = m[name]
        end
        return f.call(args)
      end
    end
    return nil
  end
end
