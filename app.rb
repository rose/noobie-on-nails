require './server.rb' 
require './router.rb' 

router = Router.new


# example with no captured variables from the route

route1 = lambda do |captures|
  return "<html><head><title>Bleep Bloop</title></head><body>Sample dynamically constructed page</body></html>"
end

router.add_route(/\/bleep/, route1)


# constructing a page using named captures from the route url

route2 = lambda do |captures|
  name = captures["person"]
  if name == ""
    name = "there"
  end
  return "<html><head><title>Hello " + name + "!</title></head><body><h1>Sample capture page</h1><br>This is a <b>FREE</b> personalized greeting for " + name + "!  Hi " + name + "!</body></html>"
end

router.add_route(/\/greet\/(?<person>[^\/]*)\/?/, route2)


# creating a server with the above routes, and running it on port 9393

Server.new({"port" => 9393, "router" => router}).start
