function largest_common_region(input)
    coords = parse_coords(input)

    boundaries = found_bounds(coords)

    c_x = Int(round((boundaries.max_x + boundaries.min_x) / 2))
    c_y = Int(round((boundaries.max_y + boundaries.min_y) / 2))
    center = Point(-1, c_x, c_y)
    println(center)

    seen = Set{Point}()
    radius = 0
    found_new_points = true
    while found_new_points
        println("Using rad $(radius)")
        found_new_points = false
        for neighbor in points_around(center, radius)
            if neighbor in seen
                continue
            end

            if within_distance(coords, neighbor, 10000)
                found_new_points = true
                push!(seen, neighbor)
            end
        end
        radius += 1
    end

    return length(seen)
end

function within_distance(points, neighbor, max_distance)
    total_distance = 0
    for p in points
        distance = abs(p.x - neighbor.x) + abs(p.y - neighbor.y)

        total_distance += distance
        if total_distance >= max_distance
            return false
        end
    end
    return true
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

    println(largest_common_region(input))
end

main()