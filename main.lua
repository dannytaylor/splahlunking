debug = true

-- main.lua

class 	= require 'lib/middleclass'
lume    = require 'lib/lume'    	-- basic helper functions   https://github.com/rxi/lume/
gamera  = require 'lib/gamera'
bump    = require 'lib/bump'		-- collisions 				https://github.com/kikito/bump.lua
sodapop = require 'lib/sodapop'		-- sprite anim 				https://github.com/tesselode/sodapop
sock    = require 'lib/sock'		-- networking				https://github.com/camchenry/sock.lua

bitser  = require "lib/bitser"
-- binser  = require "lib/binser"


require 'init'
require 'input'
require 'sockhelper'

require 'obj/Map'
require 'obj/Player'
require 'obj/Treasure'
require 'obj/UI'
require 'obj/Bubbler'
require 'obj/Menu'
require 'obj/Button'
require 'obj/Screen'

players = {}
pid = nil

gamestate = 0


function love.load()
	math.randomseed(os.time())
	love.graphics.setDefaultFilter('nearest', 'nearest',0)

	init()
end


function love.update(dt)
	if client then clientUpdate(dt) end
	if server then serverUpdate(dt) end

	if gamestate == 0 then
		menu:update(dt)
	elseif gamestate == 1 then
		if not client then gametime = gametime + dt end
		for i=1,numConnected do
			players[i]:update(dt)
		end
		ui:update(dt)
		map:update(dt)
	end
end


function love.draw()
	love.graphics.clear()
	
	if gamestate == 0 then
		menu:draw()
	elseif gamestate == 1 then
		cam:draw(function()
		  	map:draw()

			for i=1,numConnected do
				players[i]:draw()
			end
		end)

		ui:draw()
	end


end