require './server.rb' 
require './route2.rb' 


route1 = lambda do |captures|
  return "<html><head><title>Bleep Bloop</title></head><body>booooooork</body></html>"
end

route2 = lambda do |captures|
  return "hello " + captures["person"] + "!"
end

router = Router.new
router.add_route(/\/bleepbloop/, route1)
router.add_route(/\/greet\/(?<person>[^\/]*)\/?/, route2)

Server.new({"port" => 9393, "router" => router}).start
