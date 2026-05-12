local Spring = {}
Spring.__index = Spring

function Spring.new(target, damping, frequency)
	local self = setmetatable({}, Spring)
	self.Target = target or 0
	self.Position = self.Target
	self.Velocity = 0
	self.Damping = damping
	self.Frequency = frequency
	return self
end

function Spring:SetTarget(target)
	self.Target = target
end

function Spring:Update(dt)
	local displacement = self.Position - self.Target
	local springForce = -self.Frequency * self.Frequency * displacement
	local dampingForce = -2 * self.Damping * self.Frequency * self.Velocity
	self.Velocity += (springForce + dampingForce) * dt
	self.Position += self.Velocity * dt
	return self.Position
end

return Spring
