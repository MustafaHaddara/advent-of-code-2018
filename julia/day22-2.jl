function rescue_op(input)
    d,tx,ty = parse_input(input)

    levels = Dict()

    base_case = (d % 20183)
    levels[(0,0)] = base_case
    levels[(tx,ty)] = base_case

    # give enough extra space to go around
    # 2x wasn't big enough, but 3x was! O.o
    compute_erosion_level(d, 3*tx, 3*ty, levels)

    return time_to(tx, ty, levels)
end

function time_to(tx,ty, levels)
    types = Dict()
    for (p,l) in levels
        types[p] = l%3
    end

    start = Location(0,0,'T')
    frontier::Array{Location} = []
    costs = Dict{Location,Int}()

    push!(frontier, start)
    costs[start] = 0

    seen = Set()

    # end_costs = []

    while !isempty(frontier)
        current = pop!(frontier)
        current_pos = (current.x, current.y)
        # println("Starting at $current with cost $(costs[current])")
        for neighbor in neighbors(current_pos...)
            # print("  Exploring $neighbor")
            if !haskey(types, neighbor)
                # println("...seen this previously")
                continue
            end

            current_type = types[current_pos]
            next_type = types[neighbor]
            # println()
            # println("    $neighbor $(levels[neighbor]) $(types[neighbor])")
            nt = next_tool(current_type, next_type, current.tool)
            cost = costs[current]
            if current.tool == nt
                cost += 1
            else
                cost += 8
            end

            # print("  -> has cost $cost")

            if neighbor[1] == tx && neighbor[2] == ty
                if nt != 'T'
                    nt = 'T'
                    cost += 7
                end
                println("FOUND ROUTE COSTING $cost")
            end

            next_loc = Location(neighbor[1], neighbor[2], nt)
            # println("  -> $next_loc")

            if !haskey(costs, next_loc) || costs[next_loc] > cost
                costs[next_loc] = cost
                if !(next_loc in seen)
                    push!(frontier, next_loc)
                    push!(seen, next_loc)
                end
            end
        end
        sort!(frontier, by=f->-1*costs[f])
        # println(frontier)
    end

    println(costs[Location(tx,ty, 'T')])
    return ""
end

function next_tool(current_type, next_type, current_tool)
    tools = Dict(
        0 => ['C', 'T'],
        1 => ['C', 'N'],
        2 => ['T', 'N']
    )

    # println()
    # println("    $current_type, $next_type, $current_tool")
    if current_tool in tools[next_type]
        return current_tool
    end

    available = tools[current_type]
    next = tools[next_type]
    for tool in next
        if tool in available
            return tool
        end
    end
end

function neighbors(x,y)
    return [
        (x-1,y),
        (x+1,y),
        (x,y-1),
        (x,y+1)
    ]
end

struct Location
    x::Int
    y::Int
    tool::Char
end

function compute_erosion_level(d, x,y, levels)
    pos = (x,y)
    if haskey(levels, pos)
        return levels[pos]
    end

    if y == 0
        geo_idx = x * 16807
    elseif x == 0
        geo_idx = y * 48271
    else
        geo_idx = compute_erosion_level(d, x-1,y, levels) * compute_erosion_level(d, x,y-1, levels)
    end

    level = (geo_idx + d) % 20183
    levels[pos] = level

    return level
end

function print_levels(levels, maxx, maxy)
    for y in 0:maxy
        for x in 0:maxx
            pos = (x,y)
            v = levels[pos] % 3
            if v == 0
                ch = '.'
            elseif v == 1
                ch = '='
            else
                ch = '|'
            end
            print(ch)
        end
        println()
    end
end

function parse_input(input)
    d = split(input[1], " ")[2]
    pos = split(input[2], " ")[2]
    (x,y) = split(pos, ",")

    return map(e->parse(Int, e), (d, x, y))
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        "depth: 510",
        "target: 10,10"
    ]

    println(rescue_op(input))
end

main()