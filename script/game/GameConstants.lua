APP_TILE = "Space Monkey"

PHYS_GROUP_PLAYER = 1
PHYS_GROUP_OBJECT = 2

AppendEnum( WORLD_EVENT,
{
	"COLLISION"
})

ITEM = MakeEnum
{
	"ORE"
}

DAMAGE_TYPE = MakeEnum
{
	"KINETIC",
	"EM",
}