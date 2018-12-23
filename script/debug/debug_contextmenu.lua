local DebugUtil = require "debug/debug_util"
local debug_menus = require "debug/debug_menus"

-------------------------------------------------
-- Renders a debug panel with immediate mode GUI.

local DebugContextMenu = class( "DebugContextMenu", DebugPanel )

function DebugContextMenu:init( dbg )
    DebugPanel.init( self, dbg )
    local game = dbg:GetDebugEnv().game
    self.hovered_tile = game and game.hovered_tile
end

function DebugContextMenu:RenderPanel( dbg )
    local ui = dbg.imgui
    local world = dbg:GetDebugEnv().world
    if world then
        if ui.BeginMenu( "Debug Flags" ) then
            self:AddDebugMenu( self.dbg, ui, debug_menus.DEBUG_TOGGLES )
            ui.EndMenu()
        end
    end
end
