struct Point
    id::Int
    x::Int
    y::Int
    z::Int
    w::Int
end

function distance(p1::Point, p2::Point)
    dx = p1.x - p2.x
    dy = p1.y - p2.y
    dz = p1.z - p2.z
    dw = p1.w - p2.w

    return abs(dx) + abs(dy) + abs(dz) + abs(dw)
end

function find_constellations(input)
    points = parse_input(input)

    constellations = group_into_constellations(points)

    return length(constellations)
end

function group_into_constellations(points)
    constellations = map(p->[p], points)
    counter = 0
    while combine_constellations(constellations)
        counter += 1
        println("did $counter pass")
    end
    return constellations
end

function combine_constellations(constellations)
    made_changes = false
    for i in 1:length(constellations)
        group = constellations[i]
        for j in i+1:length(constellations)
            other = constellations[j]
            made_changes |= merge_constellations(group, other)
        end
    end
    filter!(e->!isempty(e), constellations)
    return made_changes
end

function merge_constellations(c1, c2)
    for p1 in c1
        for p2 in c2
            if distance(p1, p2) <= 3
                # merge
                append!(c1, c2)
                empty!(c2)
                return true
            end
        end
    end
    return false
end

function parse_input(input)
    points = []
    id = 1
    for l in input
        line = strip(l)
        if line == ""
            continue
        end
        chunks = split(line, ",")
        coords = map(st->parse(Int, st), chunks)
        push!(points, Point(id, coords...))
        id+=1
    end
    return points
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        " 0,0,0,0",
        " 3,0,0,0",
        " 0,3,0,0",
        " 0,0,3,0",
        " 0,0,0,3",
        " 0,0,0,6",
        " 9,0,0,0",
        "12,0,0,0",
]

    println(find_constellations(input))
end

main()