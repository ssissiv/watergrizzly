
local a1 = world:SpawnEntity( Asteroid:new() )
a1:SetPosition( 150, 300 )
a1.body:setLinearVelocity( -100, 0 )

local a2 = world:SpawnEntity( Asteroid:new() )
a2:SetPosition( 0, 350 )
a2.body:setLinearVelocity( 100, 0 )
