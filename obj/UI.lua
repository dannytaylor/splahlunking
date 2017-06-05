-- ui.lua
-- player HUD 
UI = class('UI')
cd = 4
function UI:initialize()
	self.canvas = love.graphics.newCanvas(viewW*tileSize, viewH*tileSize,"normal",0)
	self.canvas:setFilter("nearest", "nearest")

	self.breathMax = 8 -- num bubbles to display
	self.breathNum = 0
	self.scoreNum = 0
	love.graphics.setLineWidth(1)
	self.tankmsg  = sodapop.newAnimatedSprite(68,24)
	self.tankmsg:addAnimation('default', {
		image       = love.graphics.newImage('img/tankmsgsheet.png'),
		frameWidth  = 48,
		frameHeight = 16,
		frames      = {
			{1, 1, 5, 1, .4},
		},
	})
	scoreBox.active = false
	scoreBox.submitted = false
	scoreBox.text = ''

end

function UI:draw()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	-- gametime bar on bottom
	-- love.graphics.setColor(255, 255, 255)
	-- local lineend = math.max(0,math.floor(viewW*(gametimeMax-gametime)/gametimeMax))
	-- love.graphics.line(0, viewH, lineend, viewH)
	if players[pid].y < (waterLevel+2)*tileSize and players[pid].tWater < breakTime and gametime>8 then 
		love.graphics.print('DIVE!', 60, 20)
	end
	if not players[pid].win and players[pid].alive then self:breathbar() end
	self:playerbar()
	if fid == pid then self:scorebar() end
	self:countdown()

	-- if debug then
	-- 	love.graphics.setColor(255, 255, 255)
	-- 	love.graphics.print('breath: '..math.floor(players[pid].breath), 2, 0)
	-- 	love.graphics.print('score: '..players[pid].score, 2, 8)
	-- end
	if alldone then
		if not client then
			love.graphics.draw(uiSheet,uiq.host_msg,44,56)
		else 
			love.graphics.draw(uiSheet,uiq.client_msg,44,56)
		end
	end
	if not players[pid].alive then
		-- love.graphics.draw(overlay_dead, 0, 0)
		love.graphics.print('UR DEAD,BUD', 48, 12)
		love.graphics.print('YOUR SCORE:'..players[pid].score, 45, 19)

		if not alldone then
			if fid ~= pid and followtimer > deadtime then 
				love.graphics.print('WATCHING P'..fid, 50, 56) 
			else
				love.graphics.draw(uiSheet,uiq.wait_msg,44,56)
			end
		end

	elseif players[pid].surface then
		love.graphics.draw(uiSheet,uiq.alivemsg,44,12)
		love.graphics.print('YOUR SCORE:'..players[pid].score, 45, 19)
		if not alldone then
			if fid ~= pid and followtimer > deadtime then 
				love.graphics.print('WATCHING P'..fid, 50, 56) 
			else
				love.graphics.draw(uiSheet,uiq.wait_msg,44,56)
			end
		end

	-- elseif gametime > gametimeMax then
	-- 	love.graphics.draw(uiSheet,uiq.timemsg,40,16)
	elseif tankBubbler then
		-- love.graphics.draw(uiSheet,uiq.tankmsg,44,16)
		self.tankmsg:draw()
	end

	
	if not client and not server and players[pid].win and players[pid].score ~= 0 then
		if not scoreBox.active and not scoreBox.submitted then
			love.graphics.setColor(224, 111, 139)
			love.graphics.print('ENTER> ',scoreBox.x, scoreBox.y)
			love.graphics.setColor(255,255,255)
			love.graphics.print('LEADERBOARD', scoreBox.x+24, scoreBox.y)
		elseif not scoreBox.active and scoreBox.submitted then
			love.graphics.print('SCORE SUBMITTED!', scoreBox.x+6, scoreBox.y)
		else
			love.graphics.setColor(224, 111, 139)
			love.graphics.print('ENTER>>', scoreBox.x, scoreBox.y)
			love.graphics.setColor(255,255,255)
			love.graphics.print(scoreBox.text, scoreBox.x+28, scoreBox.y)
		end
	end


	love.graphics.setCanvas()
	love.graphics.draw(self.canvas, 0, 0, 0, windowScale, windowScale)
end

scoreBox = {
    x = 33,
    y = 26,
    text = '',
    active = false,
    submitted = false,
}

function love.textinput (text)
    if scoreBox.active then
    	local t = string.match(text,"%w+")
		if t then 
			t = string.upper(t)
			if string.len(scoreBox.text) <= 11 then
	        	scoreBox.text = scoreBox.text .. t
    		end	
        end
    end
end

function UI:update(dt)
	local bn = self.breathNum
	self.breathNum = math.ceil((16*players[pid].breath/100))
	self.scoreNum = math.min(math.ceil((8*players[pid].score/100)),8)

	if bn > self.breathNum and bn < 16 and bn > 1  and (bn%2) == 1 then
		sfx_bubble1:play()
	end
	if tankBubbler then
		-- love.graphics.draw(uiSheet,uiq.tankmsg,44,16)
		self.tankmsg:update(dt)
	end
end

function UI:countdown()
	if gametime <= 8 then
		if cd ~= 4-math.floor(gametime/2) and cd > 0 then sfx_countdown1:play()
		
		end
		cd = 4-math.floor(gametime/2)
		love.graphics.print('READY IN', 53, 14)
		love.graphics.print(4-math.floor(gametime/2), 66, 20)
	elseif cd == 1 or cd == 0 then 
		sfx_countdown2:play()
		cd = -1
	end
end

function UI:breathbar()

	-- tank icon
	-- if players[pid].tank then
	-- 	love.graphics.draw(uiSheet,uiq.tank1,viewW-11,viewH-12)
	-- else
	-- love.graphics.draw(uiSheet,uiq.tank2,viewW-11,viewH-12)
	if not players[pid].tank then
		local bn = math.ceil(self.breathNum/2)
		if bn>0 then
			if bn > 1 then 
				for i=1, bn-1 do
					love.graphics.draw(uiSheet,uiq.bubble_l,viewW-11, viewH-(i+1)*tileSize)
				end
			end
			if self.breathNum % 2 == 0 then
				love.graphics.draw(uiSheet,uiq.bubble_l,viewW-11, viewH-(bn+1)*tileSize)
			else
				love.graphics.draw(uiSheet,uiq.bubble_s,viewW-11, viewH-(bn+1)*tileSize)
			end
		end
	end
end

function UI:scorebar()
	-- breath bar
	local sn = self.scoreNum
	for i=1, sn do
		if i % 2 == 0 then
			love.graphics.draw(uiSheet,uiq.score1,3, viewH-(i+1)*tileSize)
		else
			love.graphics.draw(uiSheet,uiq.score2,3, viewH-(i+1)*tileSize)
		end
	end
	
end
function UI:playerbar()
	local nc = numConnected
	local topscore = 0
	if nc > 1 then
		local pscore = {0,0,0,0}
		for i=1,nc do
			if players[i].alive then
				pscore[i] = players[i].score
			else
				pscore[i] = 0
			end

			if pscore[i] > topscore then
				topscore = pscore[i] 
			end
		end
		for i=1,nc do
			local x = 54+(i-1)*9
			if players[i].connected then love.graphics.draw(uiSheet, uiq2[players[i].palette], x, 0) end
			if topscore > 0 and topscore == pscore[i] and players[i].connected then
				love.graphics.draw(uiSheet, uiq.winning, x, 4)
			elseif not players[i].alive and players[i].connected then
				love.graphics.draw(uiSheet, uiq.dead, x, 4)
			end
			if players[i].win and players[i].connected then
				love.graphics.draw(uiSheet, uiq.check, x, 0)
			end
			if i == pid then
				love.graphics.draw(uiSheet, uiq.hl, x, 0)
			end
		end
	end
	if client or server then
		if alldone and numConnected > 1 then
			if topscore == 0 then 
				love.graphics.print('NO WINNERS...', 48, 26)
			else
				love.graphics.print('WINNING SCORE:'..topscore, 40, 26)
			end
		end
	end
end


