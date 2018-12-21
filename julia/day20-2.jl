function regex_map(input)
    (rooms, i) = follow_map(input, 1, (0,0))
    println("--")
    for (p,d) in rooms
        println("$p -> $d")
    end
    return count(e->e[2]>=1000, rooms)
end

function follow_map(regex, idx, base_pos)
    # println("start follow")
    distances = Dict()

    pos = base_pos
    distances[pos] = 0
    distance = 1
    while idx <= length(regex)
        ch = regex[idx]
        if ch == '^'
            idx += 1
            continue
        end
        if ch == '$'
            break
        end
        if ch == 'N'
            new_pos = (pos[1], pos[2]+1)
            pos = new_pos
            if !haskey(distances, pos)
                distances[pos] = distance
            end
            # println("$pos -> $distance")
            distance += 1
        elseif ch == 'S'
            new_pos = (pos[1], pos[2]-1)
            pos = new_pos
            if !haskey(distances, pos)
                distances[pos] = distance
            end
            # println("$pos -> $distance")
            distance += 1
        elseif ch == 'E'
            new_pos = (pos[1]+1, pos[2])
            pos = new_pos
            if !haskey(distances, pos)
                distances[pos] = distance
            end
            # println("$pos -> $distance")
            distance += 1
        elseif ch == 'W'
            new_pos = (pos[1]-1, pos[2])
            pos = new_pos
            if !haskey(distances, pos)
                distances[pos] = distance
            end
            # println("$pos -> $distance")
            distance += 1
        elseif ch == '('
            # println("found group")
            children,i = follow_map(regex, idx+1, pos)
            for (pos,d) in children
                if !haskey(distances, pos)
                    distances[pos] = d + distance - 1
                end
            end
            idx = i
        elseif ch == '|'
            pos = base_pos
            distance = 1
            idx += 1
            continue
        elseif ch == ')'
            # println("end follow group")
            return (distances, idx)
        end

        idx += 1
    end
    # println("end follow")
    return (distances, idx)
end


function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")[1]
    
    # test_input = "^ENW\$" # 3
    test_input = "^ENWWW(NEEE|SSE(EE|N))\$" # 10
    # test_input = "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN\$" # 18
    

    println(regex_map(input))
end

main()