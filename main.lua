-----------------------------------------------------------
package.path = "script/?.lua;foreign/?/init.lua;foreign/?.lua;"..package.path
-----------------------------------------------------------

require "util/strict"
strictify( _G )

require "util/util"
constants = require "constants"
require "debug/debug_mgr"
debug_menus = require "debug/debug_menus"
loc = require "localization/locstring"
Shaders = require "render/shader_defs"

require "camera"
require "input"
require "eventsystem"

require "engine/engine_constants"
require "engine/baseworld"
require "engine/entity"
require "engine/Component"

require "gui/ui"
require "gui/Screen"

require "game/GameConstants"
require "game/Assets"
require "game/world"
require "game/WorldExt"
require "game/Ship"
require "game/StarField"
require "game/Asteroid"
require "game/SolarSystem"
require "game/Star"
require "game/components/EnergyGenerator"
require "game/components/Scanner"
require "game/frontend/game_screen"

require "imgui"

-----------------------------------------------------------

local test_window = false
local gui = nil
local debug_mgr = nil
local global_lcg = lcg()

function DBG( v )
    local debug_node = DebugUtil.CreateDebugNode( v )
    debug_mgr:CreatePanel( debug_node )
end

function DBQ( k, v )
    local env = debug_mgr:GetDebugEnv()
    return env and env[ k ] or v
end

function GetGUI()
    return gui
end

function GetDbg()
    return debug_mgr
end

function GetRand( seed )
    if seed then
        global_lcg:randomseed( seed )
    end
    return global_lcg
end

-----------------------------------------------------------
--
-- LOVE callbacks
--
function love.load(arg)
    math.randomseed( os.time() )
    
    debug_mgr = DebugManager()
    debug_mgr:AddBindingGroup( debug_menus.GAME_BINDINGS )
    debug_mgr:ExecuteDebugFile( "script/debug/consolecommands.lua" )

    local game = GameScreen.new()
    debug_mgr.game = game

    gui = UIWorld:new()
    gui:AddScreen( game )

    love.window.setTitle( APP_TILE )
end
 
function love.update(dt)
    imgui.NewFrame()
    gui:UpdateWorld( dt )
end
 
function love.draw()
    love.graphics.clear(0, 0, 0, 255)

    -- Render game UI
    gui:RenderWorld()

    -- Debug render
    debug_mgr:DoRender()

    love.graphics.setColor( 1, 1, 1 )
    imgui.Render()
end
 
function love.quit()
    imgui.ShutDown()
end
 
--
-- User inputs
--
function love.textinput(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end
 
function love.keypressed(key)
    imgui.KeyPressed(key)
    if debug_mgr:IsConsoleOpen() then
        -- while console is open, allow DebugMgr to handle keys even if ImGUI sinks them.
        debug_mgr:KeyPressed( key )

    elseif not imgui.GetWantCaptureKeyboard() then
        if not debug_mgr:KeyPressed( key ) then
            gui:KeyPressed( key )
        end
    end
end
 
function love.keyreleased(key)
    imgui.KeyReleased(key)
    if not imgui.GetWantCaptureKeyboard() then
        gui:KeyReleased( key )
    end
end
 
function love.mousemoved(x, y)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        gui:MouseMoved( x, y )
    end
end
 
function love.mousepressed(x, y, button)
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
        if not debug_mgr:MousePressed( x, y, button) then
            gui:MousePressed( x, y, button )
        end
    end
end
 
function love.mousereleased(x, y, button)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
        if not debug_mgr:MouseReleased( x, y, button) then
            gui:MouseReleased( x, y, button )
        end
    end
end
 
function love.wheelmoved(x, y)
    imgui.WheelMoved(y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
        gui:WheelMoved( x, y )
    end
end