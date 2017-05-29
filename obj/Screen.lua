-- Screen.lua

Screen = class('Screen')

function Screen:initialize()
	self.buttons = {}
	self.bgImg = nil
	self.prevScreen = nil
	self.currentButton = nil
	self.buttonIndex = nil

	-- char select specific
	self.isChar = false
	self.highlight = 1
	self.rx,self.ry = 8,20
	if pid == 2 then self.rx = 37
	elseif pid == 3 then self.rx = 66
	elseif pid == 4 then self.rx = 95	
	end
	self.currentChar = {1,1,1,1}
	love.graphics.setLineWidth(2)
end

function Screen:draw()
	if self.bgImg then love.graphics.draw(self.bgImg,0,0,0,1,1) end

	for i,b in ipairs(self.buttons) do
		b:draw()
	end
	if self.isChar then
		-- all portraits
		for i=1,numConnected do
			love.graphics.draw(charsheet,csq[self.currentChar[i]],8+(i-1)*29,20)
		end

		-- single info sheet
		love.graphics.draw(charsheet,csq[self.currentChar[pid]+5],16,56)

		--highlight local player
	
		love.graphics.setColor(247, 226, 107)
		love.graphics.rectangle('line', 8+29*(pid-1), 20, 24, 32)
		love.graphics.setColor(255, 255, 255)
	end
end

function Screen:update(dt)
end
