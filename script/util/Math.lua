class( "Math" )

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

