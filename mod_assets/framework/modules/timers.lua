fw_addModule('timers',[[
objects = {}
debug = false

-- spawn a new timer
function create(self,id,plevel)
 plevel = plevel or party.level
 local timerEntity = spawn('timer',plevel,0,0,1,id)
 id = timerEntity.id
 self.objects[id] = wrap(timerEntity)
 timerEntity:addConnector('activate','timers','callCallbacks')
 return self.objects[id]
end

function find(self,id)
	return self.objects[id]
end


function setLevels(self,levels)
	print('set levels is deprecated, remove the function call.')
end

-- create a wrapper object to timer passed as argument
function wrap(timer)
 local wrapper = {
    id = timer.id,
	level = timer.level,
    interval = 0,
    connectors = {},
	active = false,
	callbacks = {},
	tick = 0,
	addConnector = timers._addConnector,
	activate = timers._activate,
	deactivate = timers._deactivate,
	toggle = timers._toggle,	
	isActivated = timers._isActivated,		
	setInstant = timers._setInstant,
	setTimerInterval = timers._setTimerInterval,
	setConstant = timers._setConstant,
	destroy = timers._destroy,	
	addCallback = timers._addCallback,
	callCallbacks = timers.callCallbacks,
	setTickLimit = timers._setTickLimit
 }
 return wrapper
end

function _addConnector(self,paction,ptarget,pevent)
	self:addCallback(
		function(self,scriptId,functionName) 
			findEntity(scriptId)[functionName](self)
		end,
		{ptarget,pevent}
	)
end

function _activate(self)
	    self.active = true
		if self.isConstant then
			timers.objects[self.id..'_'..party.level]:activate()
		else
			findEntity(self.id):activate()
		end
		if self.instant then
			
			self:callCallbacks()
		end
end

function _deactivate(self)
	    self.active = false

		findEntity(self.id):deactivate()
		
		if (self.isConstant) then
			for l=1, getMaxLevels() do
				timers.objects[self.id..'_'..l]:deactivate()
			end
		end		
		if (type(self.onDeactivate) == 'function') then
			self.onDeactivate(self)
		end		
end

function _toggle(self)
		if (self.active) then 
			self:deactivate()
		else
			self:activate()
		end
end

function _isActivated(self)
		return self.active
end
-- If set, callbacks are called instantly after the activation of the timer.
function _setInstant(self,bool)
		self.instant = bool
end

function _setTimerInterval(self,interval)
	    self.interval = interval
		findEntity(self.id):setTimerInterval(interval)
end

function _setConstant(self)
		self.isConstant = true
		timers.copyTimerToAllLevels(self)
end

function _destroy(self)
		findEntity(self.id):destroy()
		timers.objects[self.id] = nil
		if (self.isConstant) then
			for l=1,getMaxLevels() do
				timers.objects[self.id..'_'..l]:destroy()
			end
		end
end

function _addCallback(self,callback,callbackArgs)
		callbackArgs = callbackArgs or {}
		self.callbacks[#self.callbacks+1] = {callback,callbackArgs}
		
end

function _setTickLimit(self,limit,autodestroy)
		self.limit = limit
		self.autodestroy = autodestroy
end	

function callCallbacks(timerEntity)
	local extTimer = objects[timerEntity.id]
	extTimer.tick = extTimer.tick + 1
	
	for _,callback in ipairs(extTimer.callbacks) do
		callback[1](extTimer,unpack(callback[2]))
	end
	
	if extTimer.limit and extTimer.tick >= extTimer.limit then
		extTimer:deactivate()
		if (extTimer.autodestroy) then
			-- mark as destroyed
			extTimer.destroyed = true
		end		
	end 
	
	if (extTimer.destroyed) then
		if timers.debug then print('timer '..extTimer.id..' destroyed') end
		extTimer:destroy()
	end
end

function copyTimerToAllLevels(self)

		for l=1, getMaxLevels() do
		
			local t = timers:create(self.id..'_'..l,l)
			
			-- if interval is larger than 1 second
			-- use 0.1 seconds interval and count to actual interval*10
			-- this way the gap between level changes should stay minimal
			-- Thanks to Batty for the idea 
			if self.interval >= 1 then
				t:setTimerInterval(0.1)
				self.count = 0
				t:addCallback(
					function(self,timer_id,interval) 					
						local timer = timers.objects[timer_id]
						if (self.level == party.level) then
							timer.count = timer.count + 1
						else
							self:deactivate()
							timers:find(timer_id..'_'..party.level):activate()
						end
						if (timer.count == interval*10) then
							timer:callCallbacks()
							timer.count = 0
						end
		
					end,
					{self.id,self.interval}
				)
			else
				t:setTimerInterval(self.interval)
				t:addCallback(
					function(self,timer_id) 					
						local timer = timers.objects[timer_id]
						if (self.level == party.level) then	
							timer:callCallbacks()
						else
							self:deactivate()
							timers:find(timer_id..'_'..party.level):activate()
						end
					end,
					{self.id}
				)
			end
					
		end	
		self:deactivate()
end
]]
)