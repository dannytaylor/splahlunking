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
	self.currentChar = {1,1,1,1}
	love.graphics.setLineWidth(1)
end

function Screen:draw()
	if self.bgImg then love.graphics.draw(self.bgImg,0,0,0,1,1) end

	for i,b in ipairs(self.buttons) do
		b:draw()
	end
	if self.isChar then
		-- local connection info
		if server then
			love.graphics.draw(titlebuttons,btq.hosting,73,2)
		elseif client then
			love.graphics.draw(titlebuttons,btq.connected,73,2)
		else
			-- bio img
			love.graphics.draw(charsheet,bio[1],36,10)
			love.graphics.draw(charsheet,bio[1+self.currentChar[pid]],43,16)
		end

		-- all portraits
		for i=1,numConnected do
			love.graphics.draw(charsheet,csq[self.currentChar[i]],8+(i-1)*29,12)
		end

		-- single info sheet
		love.graphics.draw(charsheet,csq[self.currentChar[pid]+5],16,55)

		-- bg map
		love.graphics.draw(titlebuttons,btq.mapbg,68,54)
		-- current map
		love.graphics.draw(titlebuttons,mapicons[mapsel],68,54+(mapsel-1)*8)


		--highlight local player
		if self.buttonIndex == 1 then
			love.graphics.setColor(247, 226, 107)
			love.graphics.rectangle('line', 8+29*(pid-1), 12, 25, 33)
			love.graphics.rectangle('line', 9+29*(pid-1), 13, 23, 31)
			love.graphics.setColor(255, 255, 255)
		elseif self.buttonIndex == 2 and not client then
			love.graphics.setColor(247, 226, 107)
			love.graphics.rectangle('line', 69, 55+8*(mapsel-1), 20, 5)
			love.graphics.setColor(255, 255, 255)
		end
	end
end

function Screen:update(dt)
end
