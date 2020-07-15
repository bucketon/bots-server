function love.load()
	print("Starting server...")
	local enet = require "enet"
	host = enet.host_create("*:6789")
	peers = {}
	single = nil
end

function love.update(dt)
	local event = host:service(100)
	while event do
	  if event.type == "connect" then
	  	print(event.peer:connect_id().." connected!")
	    if single == nil then
	    	single = event.peer
	    else
	    	print("connecting "..event.peer:connect_id().." to "..single:connect_id()..".")
	    	peers[single] = event.peer
	    	peers[event.peer] = single
	    	event.peer:send("host")
	    	single:send("peer")
	    	single = nil
	    end
	  elseif event.type == "disconnect" then
	  	peers[peers[event.peer]] = nil
	  	peers[event.peers] = nil
	  elseif event.type == "receive" then
	  	if peers[event.peer] ~= nil then
	  		peers[event.peer]:send(event.data)
	  	end
	  end
	  event = host:service()
	end
end
