-- ui.lua
-- player HUD 
UI = class('UI')
function UI:initialize()
	self.canvas = love.graphics.newCanvas(viewW*tileSize, viewH*tileSize,"normal",0)
	self.canvas:setFilter("nearest", "nearest")

	self.breathMax = 8 -- num bubbles to display
	self.breathNum = 0
	self.scoreNum = 0
	love.graphics.setLineWidth(1)
end

function UI:draw()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()

	-- gametime bar on bottom
	-- love.graphics.setColor(255, 255, 255)
	-- local lineend = math.max(0,math.floor(viewW*(gametimeMax-gametime)/gametimeMax))
	-- love.graphics.line(0, viewH, lineend, viewH)

	if not players[pid].win and players[pid].alive then self:breathbar() end
	self:playerbar()
	self:scorebar()

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
		love.graphics.draw(overlay_dead, 0, 0)

		if not alldone then
			love.graphics.draw(uiSheet,uiq.wait_msg,44,56)
		end

	elseif players[pid].surface then
		love.graphics.draw(uiSheet,uiq.alivemsg,44,16)
		if not alldone then
			love.graphics.draw(uiSheet,uiq.wait_msg,44,56)
		end

	-- elseif gametime > gametimeMax then
	-- 	love.graphics.draw(uiSheet,uiq.timemsg,40,16)
	elseif tankBubbler then
		love.graphics.draw(uiSheet,uiq.tankmsg,44,16)
	end



	love.graphics.setCanvas()
	love.graphics.draw(self.canvas, 0, 0, 0, windowScale, windowScale)
end

function UI:update(dt)
	self.breathNum = math.floor((16*players[pid].breath/100))
	self.scoreNum = math.min(math.floor((8*players[pid].score/80)),8)
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
	if nc > 1 then
		local topscore = 0
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
			love.graphics.draw(uiSheet, uiq2[players[i].palette], x, 0)
			if topscore > 0 and topscore == pscore[i] then
				love.graphics.draw(uiSheet, uiq.winning, x, 4)
			elseif not players[i].alive then
				love.graphics.draw(uiSheet, uiq.dead, x, 4)
			end
			if i == pid then
				love.graphics.draw(uiSheet, uiq.hl, x, 0)
			end
		end
	end
end

