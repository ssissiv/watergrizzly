local constants = require "constants"

local cards =
{
	exp1 =
	{
		name = "1 EXP",
		desc = "Worth 1 experience point",
		kind = constants.CARD.EXP,
		on_draw = function ( gstate )
			gstate:addResource( constants.RESOURCE.EXP, 1 )
		end,
		cost = 0,
	},
	exp2 =
	{
		name = "2 EXP",
		desc = "Worth 2 experience points",
		kind = constants.CARD.EXP,
		on_draw = function ( gstate )
			gstate:addResource( constants.RESOURCE.EXP, 2 )
		end,
		cost = 3,
	},
	exp3 =
	{
		name = "3 EXP",
		desc = "Worth 3 experience points",
		kind = constants.CARD.EXP,
		on_draw = function ( gstate )
			gstate:addResource( constants.RESOURCE.EXP, 3 )
		end,
		cost = 6,
	},
	prestige1 =
	{
		name = "1 Prestige",
		desc = "Worth 1 prestige",
		kind = constants.CARD.PRESTIGE,
		on_acquire = function( gstate )
			gstate:addResource( constants.RESOURCE.PRESTIGE, 1 )
		end,
		on_trash = function( gstate )
			gstate:addResource( constants.RESOURCE.PRESTIGE, -1 )
		end,
		value = 1,
		cost = 2,
	},
	prestige3 =
	{
		name = "3 Prestige",
		desc = "Worth 3 prestige",
		kind = constants.CARD.PRESTIGE,
		on_acquire = function( gstate )
			gstate:addResource( constants.RESOURCE.PRESTIGE, 3 )
		end,
		on_trash = function( gstate )
			gstate:addResource( constants.RESOURCE.PRESTIGE, -3 )
		end,
		value = 3,
		cost = 5,
	},
	prestige6 =
	{
		name = "6 Prestige",
		desc = "Worth 6 prestige",
		kind = constants.CARD.PRESTIGE,
		on_acquire = function( gstate )
			gstate:addResource( constants.RESOURCE.PRESTIGE, 6 )
		end,
		on_trash = function( gstate )
			gstate:addResource( constants.RESOURCE.PRESTIGE, -6 )
		end,
		value = 6,
		cost = 8,
	},
	search =
	{
		name = "Search",
		desc = "Discard 1, Draw 1",
		kind = constants.CARD.ACTION,
		cost = 3,
		on_use = function( gstate )
			local modal_discard = require "modal_discard"
			local discards = gstate:push( modal_discard.new( gstate ))
			gstate.deck:draw(1)
		end,
	},
	focus =
	{
		name = "Focus",
		desc = "Trash up to 4 cards in hand",
		kind = constants.CARD.ACTION,
		cost = 2,
		on_use = function( gstate )
			local modal_trash = require "modal_trash"
			gstate:push( modal_trash.new( gstate, 4 ))
		end,
	},
	scout =
	{
		name = "Scout",
		desc = "Scout the environs. +1 Card, +2 Actions",
		kind = constants.CARD.ACTION,
		cost = 3,
		on_use = function( gstate )
			gstate:addResource( constants.RESOURCE.ACTION, 2 )
			gstate.deck:draw( 1 )
		end,
	},
	true_grit =
	{
		name = "True Grit",
		desc = "Put your nose to the grindstone. +2 Cards, +1 Action",
		kind = constants.CARD.ACTION,
		cost = 5,
		on_use = function( gstate )
			gstate:addResource( constants.RESOURCE.ACTION, 1 )
			gstate.deck:draw( 2 )
		end,
	},
	travel =
	{
		name = "Long Strider",
		desc = "A step is the start of a journey.",
		kind = constants.CARD.ACTION,
		cost = 2,
		on_use = function( gstate )
			gstate:setResource( constants.RESOURCE.BUYS, 0 )
			gstate:addResource( constants.RESOURCE.ACTION, 3 )
		end,
	},
	train =
	{
		name = "Train",
		desc = "Self-discipline is the bedrock of successful growth. +1 Buy, +2 EXP",
		kind = constants.CARD.ACTION,
		on_use = function( gstate )
			gstate:addResource( constants.RESOURCE.EXP, 2 )
			gstate:addResource( constants.RESOURCE.BUYS, 1 )
		end,
		cost = 3,
	},
	strategist =
	{
		name = "Strategist",
		desc = "A dearth of options is the root of all panic. +3 Cards",
		kind = constants.CARD.ACTION,
		on_use = function( gstate )
			gstate.deck:draw( 3 )
		end,
		cost = 3,
	},
	planner =
	{
		name = "Planner",
		desc = "Cover all the bases. +1 Buy, +1 Action, +1 Card, +1 EXP",
		kind = constants.CARD.ACTION,
		on_use = function( gstate )
			gstate:addResource( constants.RESOURCE.EXP, 1 )
			gstate:addResource( constants.RESOURCE.BUYS, 1 )
			gstate:addResource( constants.RESOURCE.ACTION, 1 )
			gstate.deck:draw( 1 )
		end,
		cost = 5,
	},
	insight =
	{

		name = "Insight",
		desc = "Knowledge is power. Trash 1 EXP card, gain an EXP card costing up to 3 more.",
		kind = constants.CARD.ACTION,
		on_use = function( gstate )
			local function isExpCard( card )
				return card.kind == constants.CARD.EXP
			end
			local modal_trash = require "modal_trash"
			local trashed = gstate:push( modal_trash.new( gstate, 1, isExpCard ))
			if #trashed == 1 then
				local function canPickCard( card )
					return card.kind == constants.CARD.EXP and card.cost <= trashed[1].cost + 3
				end
				local modal_pickup = require "modal_pickup"
				gstate:push( modal_pickup.new( gstate, 1, canPickCard ))
			end
		end,
		cost = 5,
	},
	
}

return cards
