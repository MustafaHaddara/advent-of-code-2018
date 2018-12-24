struct Bot
    x::Int
    y::Int
    z::Int
    r::Int
end

struct Rect
    xmin::Int
    xmax::Int
    ymin::Int
    ymax::Int
    zmin::Int
    zmax::Int
end

function Rect(b::Bot)
    return Rect(b.x-b.r, b.x+b.r,
                b.y-b.r, b.y+b.r,
                b.z-b.r, b.z+b.r)
end

function emergency_teleport(input)
    bots = parse_input(input)
    intersections = intersection_of_most(map(b->Rect(b), bots))
    
    best_spot = find_best_spot(intersections, bots)
    return distance_to_origin(best_spot)
end

function find_best_spot(intersections::Array{Rect}, bots::Array{Bot})
    most_matched = -1
    closest = Bot(0,0,0,0)

    for i in intersections
        (spot, matched) = find_best_spot_for_rect(i, bots)
        dist = distance_to_origin(spot)
        # println("Found position: ($(spot.x),$(spot.y),$(spot.z)) in range of $matched other bots at $dist away")
        if matched > most_matched || 
                (matched == most_matched && dist < distance_to_origin(closest))
            # we found more matches
            # or we found the same # of matches, but closer
            most_matched = matched
            closest = spot
        end
    end

    return closest
end

function find_best_spot_for_rect(r::Rect, bots::Array{Bot})
    num_steps = 10

    xrange = r.xmax - r.xmin
    yrange = r.ymax - r.ymin
    zrange = r.zmax - r.zmin

    if xrange < num_steps && yrange < num_steps && zrange < num_steps
        best_spot = Bot(r.xmin, r.ymin, r.zmin, 0)
        num_matched = num_in_range(best_spot, bots)
        return (best_spot, num_matched)
    end


    dx = max(Int(round(xrange / num_steps)), 1)
    dy = max(Int(round(yrange / num_steps)), 1)
    dz = max(Int(round(zrange / num_steps)), 1)

    most_matched = -1
    best_box = nothing

    x = r.xmin
    while x <= r.xmax

        y = r.ymin
        while y <= r.ymax

            z = r.zmin
            while z <= r.zmax

                # do stuff here
                point = Bot(x,y,z, -1)
                matched = num_in_range(point, bots)
                if matched > most_matched || most_matched == -1
                    most_matched = matched
                    xspan = Int(round(dx/2))
                    yspan = Int(round(dy/2))
                    zspan = Int(round(dz/2))
                    best_box = Rect(x-xspan, x+xspan, y-yspan, y+yspan, z-zspan, z+zspan)
                end

                z += dz
            end

            y+=dy
        end

        x+=dx
    end

    return find_best_spot_for_rect(best_box, bots)
end

num_in_range(point, bots) = count(b->in_range(b, point), bots)
in_range(base, other) = distance_between(base, other) <= base.r

function intersection_of_most(rects)
    potential_intersections = Dict{Rect, Int}()
    for i in 1:length(rects)
        skipped = []
        intersection = rects[i]
        for j in 1:length(rects)
            if i == j
                continue
            end
            other = rects[j]
            new_intersection = find_intersection(intersection, other)
            if new_intersection == nothing
                push!(skipped, other)
            else
                intersection = new_intersection
            end
            
            if length(skipped) > 200
                break
            end
        end
        
        if length(skipped) <= 200
            if !(haskey(potential_intersections, intersection))
                potential_intersections[intersection] = length(skipped)
            end
        end
    end

    return sort(collect(keys(potential_intersections)), by=i->potential_intersections[i])
end

function find_intersection(rect_a::Rect, rect_b::Rect)
    (xmin,xmax) = find_bounds(rect_a, rect_b, get_bounds_x)
    (ymin,ymax) = find_bounds(rect_a, rect_b, get_bounds_y)
    (zmin,zmax) = find_bounds(rect_a, rect_b, get_bounds_z)

    if nothing in [xmin,xmax,ymin,ymax,zmin,zmax]
        return nothing
    end

    return Rect(xmin,xmax,ymin,ymax,zmin,zmax)
end

function find_bounds(rect_a::Rect, rect_b::Rect, get_bounds)
    amin,amax = get_bounds(rect_a)
    bmin,bmax = get_bounds(rect_b)

    imin = nothing
    imax = nothing

    if bmin <= amin && amin < bmax
        imin = amin
    elseif amin <= bmin && bmin < amax
        imin = bmin
    end

    if bmin < amax && amax <= bmax
        imax = amax
    elseif amin < bmax && bmax <= amax
        imax = bmax
    end

    return (imin, imax)
end

get_bounds_x(r::Rect) = (r.xmin, r.xmax)
get_bounds_y(r::Rect) = (r.ymin, r.ymax)
get_bounds_z(r::Rect) = (r.zmin, r.zmax)

function distance_to_origin(b::Bot)
    return distance_between(b, Bot(0,0,0,0))
end

function distance_between(ba::Bot, bb::Bot)
    dx = ba.x - bb.x
    dy = ba.y - bb.y
    dz = ba.z - bb.z

    return abs(dx) + abs(dy) + abs(dz)
end

function parse_input(input)
    bots::Array{Bot} = []
    for row in input
        if row == ""
            break
        end
        chunks = split(row, " ")
        pos_chunk = chunks[1][length("pos=<")+1:end-2]
        rad_chunk = chunks[2][3:end]

        coords = map(c->parse(Int, c), split(pos_chunk, ","))
        r = parse(Int, rad_chunk)

        b = Bot(coords..., r)
        push!(bots, b)
    end

    return bots
end

# 10->12, 12->14, 10->14
function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        "pos=<10,12,12>, r=2",
        "pos=<12,14,12>, r=2",
        "pos=<16,12,12>, r=4",
        "pos=<14,14,14>, r=6",
        "pos=<50,50,50>, r=200",
        "pos=<10,10,10>, r=5"
    ]

    println(emergency_teleport(input))
end

main()