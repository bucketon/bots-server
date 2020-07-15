function love.load()
	local enet = require "enet"
	host = enet.host_create("*:6789")
	peers = {}
	single = nil
	logs = {}
end

function love.update(dt)
	local event = host:service(100)
	while event do
	  if event.type == "connect" then
	  	log(event.peer:connect_id().." connected!")
	    if single == nil then
	    	single = event.peer
	    else
	    	log("connecting "..event.peer:connect_id().." to "..single:connect_id()..".")
	    	peers[single] = event.peer
	    	peers[event.peer] = single
	    	event.peer:send("host")
	    	single:send("peer")
	    	single = nil
	    end
	  elseif event.type == "receive" then
	  	peers[event.peer]:send(event.data)
	  end
	  event = host:service()
	end
end

function log(message)
	logs[#logs+1] = message
end

function love.draw()
	local logMessage = ""
	local firstLog = math.max(1, #logs - 10)
	for i=firstLog,#logs do
		logMessage = logMessage..logs[i].."\n"
	end
	love.graphics.print(logMessage, 0, 0)
end
