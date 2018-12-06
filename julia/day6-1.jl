function biggest_finite_region(input)
    coords = parse_coords(input)

    points_owned = Dict{Int, Array{Point}}()

    boundaries = found_bounds(coords)

    seen = Set{Point}()
    skipme = Set{Point}()
    radius = 0
    found_new_points = true
    while found_new_points
        println("Using rad $(radius)")
        found_new_points = false
        for p in coords
            if outside(p, boundaries)
                push!(skipme, p)
                continue
            end

            if p in skipme
                continue
            end

            println("Investigating $p")

            for neighbor in points_around(p, radius)
                # println("Neighbor at $(neighbor)")
                if neighbor in seen
                    continue
                end
                push!(seen, neighbor)

                closest = closest_point(neighbor, coords)
                if closest == nothing
                    # println("$(neighbor) is eq")
                    continue
                end

                if outside(neighbor, boundaries)
                    # if we're out here, we'll go forever
                    delete!(points_owned, closest.id)
                    push!(skipme, p)
                end

                found_new_points = true

                if !haskey(points_owned, closest.id)
                    points_owned[closest.id] = []
                end
                push!(points_owned[closest.id], neighbor)
            end
        end
        radius += 1
    end

    most_owned = nothing
    num_most_owned = -1
    for (point_id, owned) in points_owned
        num_owned = length(owned)
        if num_most_owned == -1 || num_owned > num_most_owned
            num_most_owned = num_owned
            most_owned = point_id
        end
    end

    # println(points_owned)
    return num_most_owned
end

function outside(point, bounds)
    return point.x >= bounds.max_x || point.x <= bounds.min_x || point.y >= bounds.max_y || point.y <= bounds.min_y
end

function found_bounds(points)
    min_x = points[1].x
    min_y = points[1].y
    max_x = points[1].x
    max_y = points[1].y

    for p in points[2:end]
        if p.x > max_x
            max_x = p.x
        end

        if p.y > max_y
            max_y = p.y
        end

        if p.x < min_x
            min_x = p.x
        end

        if p.y < min_y
            min_y = p.y
        end
    end

    return Bounds(min_y, max_y, min_x, max_x)
end


function closest_point(point, others)
    min_distance = -1
    closest = []
    for candidate in others
        distance = abs(point.x - candidate.x) + abs(point.y - candidate.y)
        # println("distance between $(candidate) and $(point) is $(distance)")

        if min_distance == distance
            push!(closest, candidate)
        end
        if min_distance == -1 || distance < min_distance
            min_distance = distance
            closest = [candidate]
        end
    end
    if length(closest) == 1
        return closest[1]
    else
        return nothing
    end
end

function points_around(base, radius)
    max_x = base.x + radius
    min_x = base.x - radius
    max_y = base.y + radius
    min_y = base.y - radius

    points = []
    for x in min_x:max_x
        push!(points, Point(-1, x, min_y))
        push!(points, Point(-1, x, max_y))
    end

    for y in min_y+1:max_y-1
        push!(points, Point(-1, max_x, y))
        push!(points, Point(-1, min_x, y))
    end

    return points
end

function parse_coords(input)
    coords = []
    id = 1
    for line in input
        if line == ""
            continue
        end
        chunks = split(line, ",")
        x = parse(Int, strip(chunks[1]))
        y = parse(Int, strip(chunks[2]))
        push!(coords, Point(id, x, y))
        id+=1
    end
    return coords
end

struct Bounds
    min_y::Int
    max_y::Int
    min_x::Int
    max_x::Int
end

struct Point
    id::Int
    x::Int
    y::Int
end

Base.show(io::IO, p::Point) = print(io, "Point id=$(p.id) at $(p.x),$(p.y)")

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = ["1, 1","1, 6","8, 3","3, 4","5, 5","8, 9"]

    println(biggest_finite_region(input))
end

main()