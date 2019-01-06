-- Gameplay yields

DEFAULT_WORLD_SPEED = 1	-- 1 unit of world time (day) per 1 wall seconds.
MAX_WORLD_SPEED = DEFAULT_WORLD_SPEED * 2^5

WALL_TIME_TO_TICK = 1	-- 1 tick per 0.1 wall seconds


DEFAULT_ZOOM = 1.0
MIN_ZOOM = -16
MAX_ZOOM = 256

CAMERA_BOUNDS_LEFT = -800
CAMERA_BOUNDS_RIGHT = 800
CAMERA_BOUNDS_BOTTOM = -500
CAMERA_BOUNDS_TOP= 500

PAUSE_TYPE = MakeEnum{ "DEBUG", "GAME" }

-- Engine world events

WORLD_EVENT = MakeEnum{
	"LOG",
	"INPUT"
}

