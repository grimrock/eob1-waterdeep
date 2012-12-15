fw_addModule('fw_fx',[[
effects = {}
function addProjectileEffect(projectile,effectName,speed,onHitEffectName,sound,onHitSound,offset)
    offset = offset or 1
	local timer = spawn('timer',projectile.level,projectile.x,projectile.y,projectile.facing)
	local effect = spawn('fx',projectile.level,projectile.x,projectile.y,projectile.facing)
	effects[timer.id] = {}
	effects[timer.id].projectile_id = projectile.id
	effects[timer.id].effect_id =  effect.id
	effects[timer.id].x = 0
	effects[timer.id].y = 0
	effects[timer.id].onHitEffect= onHitEffectName
	effects[timer.id].onHitSound = onHitSound
	
	local dx,dy = getForward(projectile.facing)
	dy = -1 * dy
	local framerate = 1/24
	effects[timer.id].x = dx * framerate * speed
	effects[timer.id].y = dy * framerate * speed
	effects[timer.id].px = projectile.x
	effects[timer.id].py = projectile.y	
	if sound then
		playSoundAt(sound,effect.level,effect.x,effect.y)
	end
	timer:addConnector('activate','fw_fx','move_effect')
	timer:setTimerInterval(framerate)
	local light = getLightPreset(effectName)
	if light then
		effect:setLight(unpack(light))
	end
	
	effect:translate(-0.04*dx,offset,-0.04*dy)
	effect:setParticleSystem(effectName)
	timer:activate()	
	return effects[timer.id]
end

function getLightPreset(preset)
	--FX:setLight(red, green, blue, brightness, range, time, castShadow)
	local s = {}
	s['fireball'] = {1, 0.5, 0.25,15,7,200,false} 
	s['fireball_hit'] = {1, 0.5, 0.25,40,7,1,true}
	s['magic_missile'] = {1, 1, 1,15,7,200,false}
	s['poison_bolt'] = {0.25, 0.6, 0.2,4,4,200,false}
	s['lightning_bolt'] = {0.25, 0.5, 1,16,10,200,false}
	s['lightning_bolt_hit'] = {0.25, 0.5, 1,40,10,2,true}
	s['magic_missile_hit'] = {1, 1, 1,40,10,1,true}
	s['ice_storm_hit'] = {0.25, 0.5, 1,40,10,2,false}
	s['cone_of_cold_hit'] = {0.25, 0.5, 1,40,10,2,false}
	return s[preset]

end


function move_effect(timer)
	local e = effects[timer.id]
	local p = findEntity(e.projectile_id)

	local fx = findEntity(e.effect_id)
	if not p then
		if e.onHitEffect then
			local ohfx = spawn('fx',fx.level,e.px,e.py,fx.facing)
			ohfx:setParticleSystem(e.onHitEffect)
			ohfx:translate(0,1,0)
			local light = getLightPreset(e.onHitEffect)
			if light then
				ohfx:setLight(unpack(light))
			end			
			--fw.executeEntityHooks('effects','onDestroy')
		end
		if e.onHitSound then
			playSoundAt(e.onHitSound,fx.level,e.px,e.py)
		end 
		effects[timer.id] = nil
		timer:deactivate()
		timer:destroy()
		fx:destroy()
		return
	end
	e.px = p.x
	e.py = p.y	
	fx:translate(e.x,0,e.y)	
end

function playSoundOn(sound,e)
	playSoundAt(sound,e.level,e.x,e.y)
end
]])