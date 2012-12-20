local ClassFactory = {}

local function AddClass( constructor )
    local obj = constructor()
    assert(type(obj.ClassType) == "string", 'Attempting to add a class constructor which does not follow our class idiom!\nMissing ClassType string field.')
    ClassFactory[obj.ClassType] = constructor
end

local function Construct( class_name, ... )
    assert(ClassFactory[class_name]~=nil, 'Attempting to create object of unregistered class type "'..class_name..'"!')
    return ClassFactory[class_name](...)
end

local function class_type( obj )
    if type(obj)=="table" then
        return obj.ClassType
    end
end
local function total_type( obj )
    return class_type(obj) or type(obj)
end

return
{
    ModuleName = 'ClassFactory',
    AddClass = AddClass,
    Construct = Construct,
    class_type = class_type,
    total_type = total_type,
}