class( "Math" )

Math.E = 2.718281728459045

function Math.Length( x, y )
	return math.sqrt( x*x + y*y )
end

function Math.Dist(x1, y1, x2, y2)
    local dx = x2-x1
    local dy = y2-y1
    return math.sqrt( dx*dx + dy*dy )
end

function Math.Normalize( x, y )
    local mag = math.sqrt(x*x+y*y)
    if mag > 0 then
        return x/mag, y/mag
    end
    return 0,0
end

function Math.Dot( x1, y1, x2, y2 )
	return x1 * x2 + y1 * y2
end

function Math.RandomDirection()
    local angle = math.random() * 2 * math.pi
    return math.cos( angle ), math.sin( angle )
end

function Math.Sigmoid( x )
    return 1 / (1 + Math.E^-x)
end

