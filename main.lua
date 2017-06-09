debug = true

-- main.lua

class 	= require 'lib/middleclass'
lume    = require 'lib/lume'    	-- basic helper functions   https://github.com/rxi/lume/
gamera  = require 'lib/gamera'
bump    = require 'lib/bump'		-- collisions 				https://github.com/kikito/bump.lua
sodapop = require 'lib/sodapop'		-- sprite anim 				https://github.com/tesselode/sodapop
sock    = require 'lib/sock'		-- networking				https://github.com/camchenry/sock.lua
Dreamlo = require "lib/dreamlo"			-- leaderboards				

function loadrequire(module)
	local function requiref(module)
		require(module)
	end
	res = pcall(requiref,module)
	if not(res) then
		dreamlo_secret = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
		print('no dreamlo code')
	end
end
loadrequire("lib/dreamlo_secret") -- private leaderboard code					
	

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

		lmupdate(dt)

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
		lmdraw()
		ui:draw()
	end

end


lmdt = 0 
lmtimer = 1

function lmupdate(dt)
	if lmdt ~= 0 then
		if lmdt < 0 and lmtimer >= 0 then
			lmtimer = lmtimer + dt*lmdt*2
			if lmtimer <= 0 then
				lmtimer = 0
				lmdt = 0
			end
		elseif lmdt > 0 and lmtimer <= 1 then
			lmtimer = lmtimer + dt*lmdt*2
			if lmtimer >= 1 then
				lmtimer = 1
				lmdt = 0
			end
		end
	end
end

function lmdraw()
	if mapsel ~= 3 then
		love.graphics.setCanvas(lcanvas)
		if mapsel == 1 then love.graphics.clear(0,0,0,255) 
		elseif mapsel == 2 then love.graphics.clear(27, 38, 50,255) end
		love.graphics.setBlendMode("replace")
		love.graphics.setColor(0, 0, 0, 0)
		love.graphics.circle('fill', viewW/2+3, viewH/2+2, viewH/1.7+viewH*lmtimer/2.4)
		love.graphics.setColor(255, 255, 255)
		love.graphics.setBlendMode("alpha")
		love.graphics.setCanvas()

		love.graphics.draw(lcanvas, 0,0,0,windowScale,windowScale)
	end
end

lcanvas = love.graphics.newCanvas(128, 80)
lcanvas:setFilter("nearest", "nearest")
pcirc = love.graphics.newCanvas(128, 80)
pcirc:setFilter("nearest", "nearest")