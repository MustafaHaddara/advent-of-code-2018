function sum_child(input)
    nums = split(input, " ")
    result = total_for_node(nums)

    return result
end

function total_for_node(nums)
    num_children = parse(Int, popfirst!(nums))
    num_metadata = parse(Int, popfirst!(nums))
    all_childs = []
    for i in 1:num_children
        append!(all_childs, total_for_node(nums))
    end
    total = 0
    if length(all_childs) == 0
        for i in 1:num_metadata
            meta = parse(Int, popfirst!(nums))
            total += meta
        end
    else 
        for i in 1:num_metadata
            meta = parse(Int, popfirst!(nums))
            if meta <= length(all_childs)
                total += all_childs[meta]
            end
        end
    end
    return [total]
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")[1]
    test_input = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"

    println(sum_child(input))
end

main()