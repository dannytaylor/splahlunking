-- ui.lua

UI = class('UI')
function UI:initialize()
	self.canvas = love.graphics.newCanvas(viewW*tileSize, viewH*tileSize,"normal",0)
	self.canvas:setFilter("nearest", "nearest")

	self.breathMax = 8 -- num bubbles to display
	self.breathNum = 0
	self.scoreNum = 0
end

function UI:draw()
	if players[pid].gamestate == 'wet' then
		love.graphics.setCanvas(self.canvas)
		love.graphics.clear()


		self:breathbar()
		-- self:playerbar()
		self:scorebar()

		-- if debug then
		-- 	love.graphics.setColor(255, 255, 255)
		-- 	love.graphics.print('breath: '..math.floor(players[pid].breath), 2, 0)
		-- 	love.graphics.print('score: '..players[pid].score, 2, 8)
		-- end

		love.graphics.setCanvas()
		love.graphics.draw(self.canvas, 0, 0, 0, windowScale, windowScale)
	end
end

function UI:update(dt)
	self.breathNum = math.floor((16*players[pid].breath/100))
	self.scoreNum = math.min(math.floor((8*players[pid].score/100)),8)
end

function UI:breathbar()
	-- breath bar
	local bn = math.ceil(self.breathNum/2)
	if bn>0 then
		for i=1, bn do
			love.graphics.draw(uiSheet,uiq.bubble_l,viewW-11, viewH-(i+1)*tileSize)
		end
		if self.breathNum % 2 == 0 then
			love.graphics.draw(uiSheet,uiq.bubble_l,viewW-11, viewH-(bn+1)*tileSize)
		else
			love.graphics.draw(uiSheet,uiq.bubble_s,viewW-11, viewH-(bn+1)*tileSize)
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

