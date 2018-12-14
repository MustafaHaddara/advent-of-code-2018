function choc_recipes(input)
    target_sequence = parse_input(input)
    recipies = [3, 7]
    elf1_pos = 1
    elf2_pos = 2

    num_made = 2

    offset = -1
    while offset == -1
        next_recipies = get_next_recipes(recipies[elf1_pos], recipies[elf2_pos])
        num_made += length(next_recipies)
        append!(recipies, next_recipies)

        elf1_pos = move_elf(elf1_pos, recipies)
        elf2_pos = move_elf(elf2_pos, recipies)

        offset = found_sequence_in_recipies(recipies, target_sequence)
    end

    return length(recipies) - length(target_sequence) - offset
end

function found_sequence_in_recipies(recipies, sequence)
    if found_sequence_in_recipies(recipies, sequence, 0) 
        return 0
    elseif found_sequence_in_recipies(recipies, sequence, 1)
        return 1
    else
        return -1
    end
end

function found_sequence_in_recipies(recipies, sequence, offset)
    if length(recipies) < (length(sequence) + offset)
        return false
    end

    i = 0
    while i < length(sequence)
        if recipies[end-i-offset] != sequence[end-i]
            return false
        end
        i += 1
    end
    return true
end

function move_elf(pos, recipies)
    delta = recipies[pos] + 1
    next_pos = (pos + delta)
    while next_pos > length(recipies)
        next_pos -= length(recipies)
    end
    return next_pos
end

function get_next_recipes(a, b)
    total = a+b
    if total < 10
        return [total]
    else
        t1 = total÷10
        t2 = total%10
        return [t1, t2]
    end
end

function parse_input(input)
    seq::Array{Int} = []
    for ch in input
        push!(seq, parse(Int, ch))
    end
    return seq
end

function print_recipies(recipies, e1, e2)
    i = 0
    while i < length(recipies)
        i += 1
        r = recipies[i]
        if i == e1
            print("($r) ")
        elseif i == e2
            print("[$r] ")
        else
            print("$r ")
        end
    end
    println()
end



function main()
    input = "286051"
    test_input = "79251"

    println(choc_recipes(input))
end

main()