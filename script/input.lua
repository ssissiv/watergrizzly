local Input = class( "Input" )

Input.LEFT_MOUSE = 1
Input.RIGHT_MOUSE = 2
Input.MIDDLE_MOUSE = 3

Input.KEY_DOWN = "key_down"
Input.KEY_UP = "key_up"
Input.MOUSE_DOWN = "mouse_down"
Input.MOUSE_UP = "mouse_up"

function Input.IsPressed( key )
    return love.keyboard.isDown( key )
end

function Input.IsShift()
	return love.keyboard.isDown( "lshift" ) or love.keyboard.isDown( "rshift" )
end

function Input.IsControl()
	return love.keyboard.isDown( "lctrl" ) or love.keyboard.isDown( "rctrl" ) 
            or love.keyboard.isDown( "lgui" ) or love.keyboard.isDown( "rgui" ) 
end

function Input.IsAlt()
	return love.keyboard.isDown( "lalt" ) or love.keyboard.isDown( "ralt" )
end

function Input.GetBindingString( binding )
    -- TODO: refer to properly localized key names.
    local str = ""
    if binding.CTRL then
        str = str.."CTRL-"
    end
    if binding.SHIFT then
        str = str.."SHIFT-"
    end
    if binding.ALT then
        str = str.."ALT-"
    end
    if binding.key then
        str = str .. binding.key
    end
    return str
end

