function sum_metadata(input)
    nums = split(input, " ")
    result = total_for_node(nums)

    return result
end

function total_for_node(nums)
    num_children = parse(Int, popfirst!(nums))
    num_metadata = parse(Int, popfirst!(nums))
    total = 0
    for i in 1:num_children
        total += total_for_node(nums)
    end
    for i in 1:num_metadata
        meta = parse(Int, popfirst!(nums))
        total += meta
    end
    return total
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")[1]
    test_input = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"

    println(sum_metadata(input))
end

main()