function choc_recipes(input)
    num_recipies = parse(Int, input)
    recipies = [3, 7]
    elf1_pos = 1
    elf2_pos = 2

    num_made = 2

    while num_made < num_recipies+10
        next_recipies = get_next_recipes(recipies[elf1_pos], recipies[elf2_pos])
        num_made += length(next_recipies)
        append!(recipies, next_recipies)

        elf1_pos = move_elf(elf1_pos, recipies)
        elf2_pos = move_elf(elf2_pos, recipies)

    end
    return join(recipies[end-9:end], "")
end

function move_elf(pos, recipies)
    delta = recipies[pos] + 1
    next_pos = (pos + delta)
    while next_pos > length(recipies)
        next_pos -= length(recipies)
    end
    return next_pos
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

function main()
    input = "286051"
    test_input = "9"

    println(choc_recipes(input))
end

main()