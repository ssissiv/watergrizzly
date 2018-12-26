return {
	CONSOLE = {
		docked = true,
		history = {
			"world.location.speed = -1000",
			"world.location.speed = -100",
			"world.location.speed = 0",
			"print(world.ship:GetPosition())",
			"print(world.player:GetPosition())",
			"print( Assets.IMGS)",
			"print( Assets.IMGS.PARTICLE)",
			"DBG(Assets.IMGS)",
			"print( t.shape:computeMass() )",
			"print( t.shape:computeMass( t.shape:getDensity() ) )",
			"print(t.shape:getDensity())",
			"print( t.shape:computeMass( 1 ) )",
			"print(t.body)",
			"print(t.body:getMass())",
			"print(player.body:getMass())",
			"print(player.body:getDamping())",
			"print(player.body:getLinearDamping())",
			"print( player.fixture:getCategory() )",
			"player.fixture:setCategory( 0, 1, nil, 1 )",
			"print(tostr(world.physics:getBodies()))",
			"print(tostr(world.entities))",
			"print(tostr(world.physics:getBodies()))",
			"print(player.body:getLinearVelocity())",
			"print(t:getCount())",
			"print(t.particles:getCount())",
			"print(t.particles:isActive())",
			"print( t )",
			"print( t.body )",
			"print( t.body:getLinearVelocity() )",
			"print( imgui.Style_PlotHistogram )",
			"print( imgui.Style_Button )",
			"print( imgui.ImGuiCol_PlotHistogram )"
		}
	},
	ROOT = {
		spawn_entity = "Creature.Fieldling"
	},
	DEBUG_FILE = "debug.lua"
}