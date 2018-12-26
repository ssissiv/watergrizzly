class( "Particles" )

function Particles.MiningEmitter()
	local ps = love.graphics.newParticleSystem( Assets.IMGS.PARTICLE, 64 )
	ps:setParticleLifetime(1, 1.5)
	ps:setSpeed( 10, 20 )
	ps:setEmissionArea( "uniform", 10, 10, 0 )
	ps:setEmissionRate( 16 )
	ps:setSizes( 0.15 )
	ps:setLinearDamping( 1 )
	ps:setColors( 1, 1, 1, 1, 0, 1, 1, 1, 0.5, 0.5, 0.5, 0 )
	ps:setSpread( 2 * math.pi )
	return ps
end