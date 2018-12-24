struct Bot
    x::Int
    y::Int
    z::Int
    r::Int
end


function emergency_teleport(input)
    bots = parse_input(input)

    sort!(bots, by=b->b.r)
    strongest_bot = bots[end]

    return count(b -> in_range(strongest_bot, b), bots)
end

function in_range(base, other)
    return distance_between(base, other) <= base.r
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

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        "pos=<0,0,0>, r=4",
        "pos=<1,0,0>, r=1",
        "pos=<4,0,0>, r=3",
        "pos=<0,2,0>, r=1",
        "pos=<0,5,0>, r=3",
        "pos=<0,0,3>, r=1",
        "pos=<1,1,1>, r=1",
        "pos=<1,1,2>, r=1",
        "pos=<1,3,1>, r=1"
    ]

    println(emergency_teleport(input))
end

main()