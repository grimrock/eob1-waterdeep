-- imported
import "mod_assets/particles/eob_teleporter_rats.lua"

-- defined
defineParticleSystem{
	name = "sewers_fog",
	emitters = {		
		-- fog
		{
			emissionRate = 150,
         	emissionTime = 0,
         	maxParticles = 500,
        	spawnBurst = false,
        	boxMin = {-4.5, 0.0,-4.5},
        	boxMax = { 4.5, 0.0, 4.5},
        	sprayAngle = {0,360},
        	velocity = {0.0,0.0},
        	objectSpace = true,
        	texture = "assets/textures/particles/smoke_01.tga",
        	lifetime = {10,10},
        	colorAnimation = false,
       	 	color0 = {0.67, 0.58, 0.13},
       		opacity = 0.02,
         	fadeIn = 5,
         	fadeOut = 5,
         	size = {2.5, 2.5},
         	gravity = {0,0.01,0},
         	airResistance = 0.5,
         	rotationSpeed = 0.05,
         	blendMode = "Translucent",
		}
		--[[
		{
			emissionRate = 1.5,
			emissionTime = 0,
			maxParticles = 100,
			boxMin = {-6, 0.1, -3},
			boxMax = { 6, 0.1,  3},
			sprayAngle = {0,30},
			velocity = {0,0},
			texture = "assets/textures/particles/smoke_01.tga",
			lifetime = {10,20},
			color0 = {0.67, 0.58, 0.13},
			opacity = 0.2,
			fadeIn = 9,
			fadeOut = 9,
			size = {4, 6},
			gravity = {0,0,0},
			airResistance = 0.1,
			rotationSpeed = 0.05,
			blendMode = "Translucent",
			objectSpace = false,
		}
		]]
		
	}
}

defineParticleSystem{
	name = "magic_glow_blue",
	emitters = {
		

		-- stars
		{
			emissionRate = 10,
			emissionTime = 0,
			maxParticles = 100,
			boxMin = {-0.1, -0.1, -0.1},
			boxMax = { 0.1,  0.1,  0.1},
			sprayAngle = {0,180},
			velocity = {0.3,0.3},
			objectSpace = false,
			texture = "assets/textures/particles/teleporter.tga",
			lifetime = {0.6,0.8},
			color0 = {3.0,3.0,4.0},
			opacity = 0.7,
			fadeIn = 0.1,
			fadeOut = 0.2,
			size = {0.05, 0.5},
			gravity = {0,0,0},
			airResistance = 5,
			rotationSpeed = 2,
			blendMode = "Additive",
		},

		-- glow
		{
			spawnBurst = true,
			emissionRate = 1,
			emissionTime = 0,
			maxParticles = 1,
			boxMin = {0,0,0.0},
			boxMax = {0,0,0.0},
			sprayAngle = {0,30},
			velocity = {0,0},
			texture = "assets/textures/particles/glow.tga",
			lifetime = {1000000, 1000000},
			colorAnimation = false,
			color0 = {0.45,0.45,0.85},
			opacity = 0.2,
			fadeIn = 0.1,
			fadeOut = 0.1,
			size = {0.8, 0.8},
			gravity = {0,0,0},
			airResistance = 1,
			rotationSpeed = 2,
			blendMode = "Additive",
			objectSpace = true,
		}
	}
}

defineParticleSystem{
	name = "drip",
	emitters = {
		-- drip
		{
			emissionRate = 3,
			emissionTime = 0,
			maxParticles = 50,
			boxMin = {0,0,0},
			boxMax = {0,0,0},
			sprayAngle = {0,5},
			velocity = {0,-3},
			texture = "assets/textures/particles/glow.tga",
			lifetime = {2, 3},
			colorAnimation = false,
			color0 = {0.25, 0.25, 0.25},
			opacity = 0.4,
			fadeIn = 0.1,
			fadeOut = 0.1,
			size = {0.05, 0.1},
			gravity = {0,-5,0},
			airResistance = 0.05,
			rotationSpeed = 0,
			blendMode = "Additive",
			depthBias = -0.0005,
			objectSpace = true,
		}

	}
}

defineParticleSystem{
	name = "sewers_pipe_water",
	emitters = {		
		{
			emissionRate = 500,
         	emissionTime = 0,
         	maxParticles = 5000,
        	spawnBurst = false,
        	boxMin = {-1, 0.6,0},
        	boxMax = {-1, 0.6,0},
        	sprayAngle = {170,180},
        	velocity = {0.1,3},
        	objectSpace = true,
        	texture = "assets/textures/particles/fog.tga",
        	lifetime = {5,5},
        	colorAnimation = false,
       	 	color0 = {0.35, 0.30, 0.08},
       		opacity = 0.1,
         	fadeIn = 0.3,
         	fadeOut = 1,
         	size = {0.1, 0.1},
         	gravity = {0,-0.85,0},
         	airResistance = 0.1,
         	rotationSpeed = 0.3,
         	blendMode = "Translucent",
		}		
	}
}
defineParticleSystem{
	name = "sewers_drainage_water",
	emitters = {		
		{
			emissionRate = 500,
         	emissionTime = 0,
         	maxParticles = 1000,
        	spawnBurst = false,
        	boxMin = {-0.5,0,-0.5},
        	boxMax = {0.5,0.2,0.5},
        	sprayAngle = {0,360},
        	velocity = {0.3,0.3},
        	objectSpace = false,
        	texture = "assets/textures/particles/fog.tga",
        	lifetime = {5,5},
        	colorAnimation = false,
       	 	color0 = {0.35, 0.30, 0.08},
       		opacity = 0.4,
         	fadeIn = 0.3,
         	fadeOut = 1,
         	size = {0.15, 0.15},
         	gravity = {0,-0.85,0},
         	airResistance = 0.1,
         	rotationSpeed = 0.3,
         	blendMode = "Translucent",
		}
	}
}