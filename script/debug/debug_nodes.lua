-------------------------------------------------------------------
-- A debug node is simply an adapter that returns debug text for
-- a "source" object, which is literally whatever it is you want to
-- be debugging.
-- It also has a notion of child nodes, and a parent node, for easy
-- traversing of data hierarchies.

local DebugUtil = require "debug/debug_util"
local debug_menus = require( "debug/debug_menus" )
local DebugNode = class( "DebugNode" )

 -- Debug nodes may have a registered class, which automatically creates this node
 -- if linked as a table and retrieved via GetTableLink().

DebugNode.REGISTERED_CLASS = nil

function DebugNode:GetName()
    return self._classname
end

function DebugNode:GetUID()
    return self._classname -- Unique identifier for ImGUI and equating recent nodes.
end

function DebugNode:GetDesc( sb )
    sb:Append( "NO NODE" )
end


--------------------------------------------------------------------
-- A debug root level node.

local DebugRoot = class( "DebugRoot", DebugNode )

DebugRoot.MENU_BINDINGS = { debug_menus.DEBUG_TOGGLES }

function DebugRoot:init( game )
    assert( game )
    self.game = game
    self.frame_times = {}
    self.frame_offset = 1

    self.settings = DebugUtil.GetLocalDebugData( "ROOT" )
    if self.settings == nil then
        self.settings = {}
        DebugUtil.SetLocalDebugData( "ROOT", self.settings )
    end
end

function DebugRoot:SaveSettings()
    DebugUtil.SaveLocalDebugData()
end

function DebugRoot:RenderPanel( ui, panel, dbg )
    ui.Text( string.format( "%s\n\n", "BUILD_ID" ))
    ui.Text( string.format( "<%.2f, %2.f>", dbg:GetDebugEnv().wx, dbg:GetDebugEnv().wy ))

    ui.Separator()

    if ui.Selectable( "UI" ) then
        panel:PushDebugValue( DebugUI( GetGUI() ) )
    end

    if self.game then
        panel:AppendTable( ui, self.game, "Game" )
        panel:AppendTable( ui, self.game.game_world, "World" )
        panel:AppendTable( ui, self.game.game_world.player )
        ui.Spacing()
    end

    if ui.TreeNodeEx( "Render", { "DefaultOpen" } ) then
        ui.Indent( 20 )
        ui.Unindent( 20 )
        ui.TreePop()
    end

    if ui.TreeNodeEx( "Textures", { "DefaultOpen" } ) then
        for k, tex in pairs( Assets.IMGS ) do
            if ui.TreeNode( k ) then
                local w, h = tex:getWidth(), tex:getHeight()
                ui.Text( w, h )
                ui.Image( tex, w, h )
                ui.TreePop()
            end
        end
        ui.TreePop()
    end
end

--------------------------------------------------------------------
-- Whenever attempting to create a panel for the value 'nil'

local DebugNil = class( "DebugNil", DebugNode )

DebugNil.PANEL_WIDTH = 200
DebugNil.PANEL_HEIGHT = 80

function DebugNil:RenderPanel( ui, panel )
    ui.TextColored( 1, 0, 0, 1, "nil" )
end
 
 --------------------------------------------------------------------
-- A debug source for a generic table

local DebugTable = class( "DebugTable", DebugNode )

function DebugTable:init( t, name, offset )
    self.t = t
    self.offset = offset
    self.name = name
    self.menu_params = { t }
end

function DebugTable:GetSubject()
    return self.t
end

function DebugTable:GetName()
    return self.name or rawstring(self.t)
end

function DebugTable:GetUID()
    return rawstring(self.t)
end

function DebugTable:RenderPanel( ui, panel )
    ui.Text( string.format( "%d fields", table.count( self.t ) ))
    ui.Separator()
    
    ui.Columns(2, "mycolumns3", false)
    local mt = getmetatable(self.t)
    if mt then
        ui.Text( "getmetatable()" )
        ui.NextColumn()

        if ui.Selectable( mt._class and mt._classname or rawstring(mt) ) then
            panel:PushNode( DebugUtil.CreateDebugNode( mt ))
        end
        ui.NextColumn()
    end
    ui.Columns(1)

    panel:AppendKeyValues( ui, self.t, self.offset )
end

--------------------------------------------------------------------
-- Dynamic, custom inspector

local DebugCustom = class( "DebugCustom", DebugNode )

function DebugCustom:init( fn )
    self.fn = fn
end

function DebugCustom:RenderPanel( ui, panel )
    self:fn( ui, panel )
end
 