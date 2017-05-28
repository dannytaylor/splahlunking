-- Screen.lua

Screen = class('Screen')

function Screen:initialize()
	self.buttons = {}
	self.bgImg = nil
	self.prevScreen = nil
	self.currentButton = nil
	self.buttonIndex = nil
end

function Screen:draw()
	if self.bgImg then love.graphics.draw(self.bgImg,0,0,0,1,1) end

	for i,b in ipairs(self.buttons) do
		b:draw()
	end
end

function Screen:update(dt)
	self:input(dt)
end

function Screen:input(dt)
	
end