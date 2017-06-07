debug = true

-- main.lua

class 	= require 'lib/middleclass'
lume    = require 'lib/lume'    	-- basic helper functions   https://github.com/rxi/lume/
gamera  = require 'lib/gamera'
bump    = require 'lib/bump'		-- collisions 				https://github.com/kikito/bump.lua
sodapop = require 'lib/sodapop'		-- sprite anim 				https://github.com/tesselode/sodapop
sock    = require 'lib/sock'		-- networking				https://github.com/camchenry/sock.lua
Dreamlo = require "lib/dreamlo"			-- leaderboards				
require "lib/dreamlo_secret"			-- private leaderboard code				

bitser  = require "lib/bitser"
-- binser  = require "lib/binser"
utf8 = require("utf8")

require 'init'
require 'input'
require 'sockhelper'


require 'obj/Map'
require 'obj/Player'
require 'obj/Treasure'
require 'obj/Breath'
require 'obj/UI'
require 'obj/Bubbler'
require 'obj/Menu'
require 'obj/Button'
require 'obj/Screen'
require 'obj/Powerup'
-- require 'obj/Trail'

players = {}
pid = nil

gamestate = 0
mute = false
if debug then mute = true end

function love.load()
	math.randomseed(os.time())
	love.graphics.setDefaultFilter('nearest', 'nearest',0)
	init()
end


function love.update(dt)
	if client then clientUpdate(dt) end
	if server then serverUpdate(dt) end

	if not mute and currentsong then
		if not currentsong:isPlaying() then
			currentsong:play()
		end
	end

	if gamestate == 0 then
		menu:update(dt)
	elseif gamestate == 1 then
		if not client then gametime = gametime + dt end
		local dc = 0 
		for i=1,numConnected do
			players[i]:update(dt)
			if not alldone and players[i].win or not players[i].alive or players[i].surface then
				dc = dc + 1
			end
		end

		-- cam swps
			if not alldone then
				if not players[pid].alive or players[pid].surface then 
					if fid ~= pid then followtimer = followtimer + dt end
					players[pid].deadtimer = players[pid].deadtimer + dt
					local cp = pid -- cam player
					for i=1, numConnected do
						if players[i].alive and not players[i].win then
							cp = i
						break end
					end
					if fid ~= cp then 
						fid = cp
						followtimer = 0
					elseif followtimer>deadtime then
						cam:setPosition(players[fid].x, players[fid].y)
					end
				end

				if dc == numConnected then
					alldone = true
				end
			end

			if alldone then
				cam:setPosition(players[pid].x, players[pid].y)
			end
		-- cam swps end

		ui:update(dt)
		map:update(dt)
		mapoverlay_update(dt)

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

			mapoverlay_draw()
		end)



		ui:draw()
	end


end