
socket = require 'socket'
sock = require 'lib/sock'
bitser  = require "lib/bitser"

function initMMServer()
	mmserver = sock.newServer('*', 22123)
	mmserver:setSerialization(bitser.dumps, bitser.loads)
	ips = {}
	mmserver:on("connect", function(data, client)
		print('new client')
	end)
	mmserver:on("connectIP", function(data, client)
		ips[#ips+1] = {
			ip = data,
			cid = client:getIndex()
		}
		print(data .. ' added for cid ' .. client:getIndex())
	end)
	mmserver:on("disconnect", function(data, client)
		local cid = client:getIndex()
		print (cid .. 'disconnected')
		for i,c in ipairs(ips) do
			if c.cid == cid then 
				print(c.ip .. ' removed for cid ' ..client:getIndex() )
				c = nil 
			end
		end
	end)
	
end

function main()
	initMMServer()
	print(mmserver:getAddress())
	while true do
		mmserver:update()
		socket.sleep(0.5)
	end
end


main()


