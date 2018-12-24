function reverse_engineer(input)
    d,tx,ty = parse_input(input)

    levels = Dict()

    base_case = (d % 20183)
    levels[(0,0)] = base_case
    levels[(tx,ty)] = base_case

    compute_erosion_level(d, tx-1, ty, levels)
    compute_erosion_level(d, tx, ty-1, levels)

    # println(levels)
    # println(length(levels))
    # print_levels(levels, tx,ty)
    return sum(map(e -> e%3, values(levels)))
end

function compute_erosion_level(d,x,y, levels)
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
    # level = l % 3
    levels[pos] = level

    return level
end

function print_levels(levels, maxx, maxy)
    for x in 0:maxx
        for y in 0:maxy
            pos = (x,y)
            v = levels[pos] % 3
            println("$pos -> $(levels[pos]) -> $v")
            if v == 0
                ch = '.'
            elseif v == 1
                ch = '='
            else
                ch = '|'
            end
            # print(ch)
        end
        # println()
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

    println(reverse_engineer(input))
end

main()