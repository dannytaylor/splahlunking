debug = true

-- main.lua
-- Object  = require 'lib/classic'  	-- simple class module    	https://github.com/rxi/classic/
class 	= require 'lib/middleclass'
lume    = require 'lib/lume'    	-- basic helper functions   https://github.com/rxi/lume/
gamera  = require 'lib/gamera'
bump    = require 'lib/bump'		-- collisions 				https://github.com/kikito/bump.lua
sodapop = require 'lib/sodapop'		-- sprite anim 				https://github.com/tesselode/sodapop
sock    = require 'lib/sock'		-- networking				https://github.com/camchenry/sock.lua
-- anim8 	= require 'anim8'			-- https://github.com/kikito/anim8

bitser  = require "lib/bitser"
binser  = require "lib/binser"


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

	init()
end


function love.update(dt)
	-- if debug then require("lib/lovebird").update() end-- debug in http://127.0.0.1:8000/ 'F1'
	
	if client then clientUpdate(dt) end
	if server then serverUpdate(dt) end

	if gamestate == 0 then
		menu:update(dt)
	elseif gamestate == 1 then
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