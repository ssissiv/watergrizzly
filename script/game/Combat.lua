class( "Combat" )

function Combat.CalculateDamageFromImpact( contact )

	local fixture1, fixture2 = contact:getFixtures()
	local body1, body2 = fixture1:getBody(), fixture2:getBody()

	-- Normal points from body1 towards body2, along the direction of the collision
	local nx, ny = contact:getNormal()

	-- body1 contributes the component of their velocity that is aligned with the normal
	local vx1, vy1 = body1:getLinearVelocity()
	local speed1 = math.max( 1, Math.Length( vx1, vy1 ))
	local impact1 = Math.Dot( vx1 / speed1, vy1 / speed1, nx, ny ) * speed1

	-- body2 contributes its velocity component, but opposite sign (since the normal points away from it)
	local vx2, vy2 = body2:getLinearVelocity()
	local speed2 = math.max( 1, Math.Length( vx2, vy2 ))
	local impact2 = -Math.Dot( vx2 / speed2, vy2 / speed2, nx, ny ) * speed2

	local damage = impact2 + impact1

	-- body1:getUserData().world:TogglePause()
	-- DBG( { nx = nx, ny = ny, vx1 = vx1, vy1 = vy1, speed1 = speed1, impact1 = impact1,
	-- 					vx2 = vx2, vy2 = vy2, speed2 = speed2, impact2 = impact2, damage = damage })
	return damage
end
