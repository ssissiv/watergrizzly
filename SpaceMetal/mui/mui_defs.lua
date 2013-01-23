-----------------------------------------------------
-- MOAI UI
-- Copyright (c) 2012-2012 Klei Entertainment Inc.
-- All Rights Reserved.

return
{
	-- Mouse Buttons
	MB_None = 0,
	MB_Left = 1,
	MB_Middle = 2,
	MB_Right = 3,

	-- Keys
	K_A = string.byte("a"),
	K_B = string.byte("b"),
	K_C = string.byte("c"),
	K_D = string.byte("d"),
	K_E = string.byte("e"),
	K_F = string.byte("f"),
	K_G = string.byte("g"),
	K_H = string.byte("h"),
	K_I = string.byte("i"),
	K_J = string.byte("j"),
	K_K = string.byte("k"),
	K_L = string.byte("l"),
	K_M = string.byte("m"),
	K_N = string.byte("n"),
	K_O = string.byte("o"),
	K_P = string.byte("p"),
	K_Q = string.byte("q"),
	K_R = string.byte("r"),
	K_S = string.byte("s"),
	K_T = string.byte("t"),
	K_U = string.byte("u"),
	K_V = string.byte("v"),
	K_W = string.byte("w"),
	K_X = string.byte("x"),
	K_Y = string.byte("y"),
	K_Z = string.byte("z"),

	K_1 = string.byte("1"),
	K_2 = string.byte("2"),
	K_3 = string.byte("3"),
	K_4 = string.byte("4"),
	K_5 = string.byte("5"),
	K_6 = string.byte("6"),
	K_7 = string.byte("7"),
	K_8 = string.byte("8"),
	K_9 = string.byte("9"),
	K_0 = string.byte("0"),

	K_BACKSPACE = 8,
	K_TAB = 9,
	K_ENTER = 13,

	K_ESCAPE = 27,

	K_SPACE = string.byte(" "),
	K_LEFT_PAREN = string.byte("("),
	K_RIGHT_PAREN = string.byte("),"),
	K_ASTERISK = string.byte("*"),
	K_AMPERSAND = string.byte("&"),
	K_CARET = string.byte("^"),
	K_PERCENT = string.byte("%"),
	K_DOLLAR = string.byte("$"),
	K_HASH = string.byte("#"),
	K_AT = string.byte("@"),
	K_EXCLAIM = string.byte("!"),

	K_LEFT_BRACKET = string.byte("["),
	K_RIGHT_BRACKET = string.byte("]"),
	K_LEFT_BRACE = string.byte("{"),
	K_RIGHT_BRACE = string.byte("}"),
	K_PIPE = string.byte("|"),
	K_BACKSLASH = string.byte("\\"),
	K_SEMI_COLON = string.byte(";"),
	K_COLON = string.byte(":"),
	K_QUOTE = string.byte("\'"),
	K_DOUBLE_QUOTE = string.byte("\""),
	K_COMMA = string.byte(","),
	K_PERIOD = string.byte("."),
	K_SLASH = string.byte("/"),
	K_LESS_THAN = string.byte("<"),
	K_RIGHT_THAN = string.byte(">"),
	K_QUESTION = string.byte("?"),
	K_MINUS = string.byte("-"),
	K_UNDERSCORE = string.byte("_"),
	K_EQUAL = string.byte("="),
	K_PLUS = string.byte("+"),

	K_SHIFT = 256,
	K_CONTROL = 257,
	K_ALT = 258,

	-- Event Types
	EVENT_ALL = 0, -- denotes ALL event types (for handlers)
	
	EVENT_MouseDown = 100,
	EVENT_MouseUp = 101,
	EVENT_MouseMove = 102,
	
	EVENT_KeyUp = 103,
	EVENT_KeyDown = 104,
	
	EVENT_OnResize = 999,
	
	-- Widget events
	EVENT_WidgetActivated = 1000,
	EVENT_WidgetDeactivated = 1001,
	
	-- Button Events
	EVENT_ButtonClick = 1100,
	EVENT_ButtonEnter = 1101,
	EVENT_ButtonLeave = 1102,
}
