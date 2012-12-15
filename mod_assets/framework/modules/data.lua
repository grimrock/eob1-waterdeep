--[[
	this module is loaded automatically
]]
fw_addModule('data',[[
registry = {}

function set(entity,key,value)
	if not data.registry[getId(entity)] then data.addEntity(entity) end
	data.registry[getId(entity)][key] = value
end

function addEntity(entity)
	data.registry[getId(entity)] = {}
end

function getId(entity)
	if type(entity) == 'string' then return entity end
	return fw.getId(entity)
end

function removeEntity(entity)
	data.registry[getId(entity)] = nil
end

function get(entity,key)
	if not data.registry[getId(entity)] then return nil end
	return data.registry[getId(entity)][key]
end

function unset(entity,key)
	if data.registry[getId(entity)] == nil then return end
	data.registry[getId(entity)][key]=nil
end
]]
)