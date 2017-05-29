-- Button.lua

Button = class('Button')

function Button:initialize(name,x,y,i1,i2,a)
	self.name = name
	self.x,self.y = x,y
	self.active = false

	self.img = i1
	self.imgActive = i2

	self.w = 32
	self.h = 32

	self.action = a or function()
		do end
	end
end

function Button:draw()
	
	if self.active then 
		-- love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
		love.graphics.draw(titlebuttons,self.imgActive,self.x,self.y)
	else
		love.graphics.draw(titlebuttons,self.img,self.x,self.y)
	end
	
end

function Button:update(dt)
end 