return {
	CONSOLE = {
		docked = true,
		history = {
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
			"print( imgui.ImGuiCol_PlotHistogram )",
			"DBG(player.scanner)",
			"DBG(player)",
			"DBG(player.scanner)",
			"print(player:GetPosition())",
			"DBG(world:GetEntitiesInRange( 483, 30, 100, {} ))",
			"t = {}",
			"DBG(world:GetEntitiesInRange( 483, 30, 100, t ))",
			"world:GetEntitiesInRange( 483, 30, 100, t ); DBG(t)",
			"print(t:GetPosition())"
		}
	},
	ROOT = {
		spawn_entity = "Creature.Fieldling"
	},
	DEBUG_FILE = "debug.lua"
}