-- Button.lua

Button = class('Button')

function Button:initialize(x,y,text,a)
	self.x,self.y = x,y or nil
	self.active = false
	self.text = text
	self.w = font:getWidth(self.text)+1 or 32
	self.h = 12
	self.action = a or function()
		do end
	end
end

function Button:draw()
	-- love.graphics.setColor(255, 255, 255)
	-- love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
	if self.active then 
		love.graphics.setColor(224,111, 139) 
		love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
	end
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(self.text, self.x+1, self.y+1)
end

function Button:update(dt)
end 