--[[ 
Status: works

]]
fw_addModule('talk',[[

queue = {}
lastSpeaker = 0

function activate()
	talk.recreateTimer()
end

function addTalkHook(entity_id,hookName,text,interval,sameAsLastOne,callback)
	if not fw.hooks[entity_id] then
		fw.hooks[entity_id] = {}
	end
	local namespace = 'talk'
	local i = 0
	while fw.hooks[entity_id][namespace] do
		i = i + 1
		namespace = 'talk_'..i
	end
	
	v = {}
	v.text = text
	v.interval = interval
	v.sameAsLastOne = sameAsLastOne
	v.entity_id = entity_id
	v.namespace = namespace
	v.hookName = hookName
	v.callback = callback
	
	fw.addHooks(entity_id,namespace,{})
	fw.setHookVars(entity_id,namespace,hookName,v)
	
	fw.hooks[entity_id][namespace][hookName] = function(self,p1,p2,p3)
		local v = fw.getHookVars()
		talk.championSays(v.text,v.interval,nil,v.sameAsLastOne,v.callback,{self,p1,p2,p3})
		fw.hooks[v.entity_id][v.namespace][v.hookName] = nil
		fw.setHookVars(v.entity_id,v.namespace,v.hookName,nil)
		
	end
	
end

function recreateTimer()
	if talk_timer then
		talk_timer:destroy()
	end
	spawn('timer',party.level,0,0,0,'talk_timer')
	talk_timer:addConnector('activate','talk','printNextFromQueue')
end

function say(def)
	talk.championSays(def.text,def.interval,def.champion,def.sameAsLastOne,def.callback,def.args)
end

function championSays(text,interval,champNumber,sameAsLastOne,callback,callbackargs)
	interval = interval or 0
	if not champNumber then
		champNumber = talk.getChampionNumber(sameAsLastOne)
	end
	lastSpeaker = champNumber
	local champName = party:getChampion(champNumber):getName()
	
	table.insert(talk.queue,{
			['text']=champName..': '..text,
			['interval']=interval,
			['callback']=callback,
			['args']=callbackargs
		}
	)
	if not talk_timer:isActivated() then
		talk_timer:setTimerInterval(interval)
		talk_timer:activate()
	end
end

function getChampionNumber(sameAsLastOne)
	if (sameAsLastOne) then
		return lastSpeaker
	end
	
	local aliveChampions = help.getAliveChampions()
	if (# aliveChampions == 1) then return aliveChampions[1] end
	
	local n = math.random(# aliveChampions)
	local ok = false
	while n == lastSpeaker do
		n = math.random(4)
	end
	return n
end

function printNextFromQueue()
   talk_timer:deactivate()
   if not talk.queue[1] then return end
   if talk.queue[1].callback then
      local args = talk.queue[1].args or {}
      if talk.queue[1].callback(unpack(args)) and (talk.queue[1]) then
         hudPrint(talk.queue[1].text)
      end
   else
      hudPrint(talk.queue[1].text)
   end 
   
   table.remove(talk.queue,1)

   if (talk.queue[1]) then
      talk.recreateTimer()
      talk_timer:setTimerInterval(talk.queue[1].interval)
      talk_timer:activate()
   end
end
]])