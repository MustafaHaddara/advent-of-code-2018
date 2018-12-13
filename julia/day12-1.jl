function plant_spread(input)
    initial_state, transformations = parse_input(input)

    state = initial_state
    num_turns = 1
    start_idx = 1
    while num_turns <= 100
        if state[1:3] != "..."
            state = "..." * state 
            start_idx += 3
        end
        if state[end-2:end] != "..."
            state = state * "..."
        end

        new_state = ".."
        for i in 1:length(state)-4
            chunk = state[i:i+4]
            result = process_chunk(chunk, transformations)
            new_state *= result
        end
        state = new_state
        num_turns += 1
    end

    return total_for(state, start_idx)
end

function total_for(state, zero_idx)
    i = 1
    total = 0
    while i <= length(state)
        real_idx = i - zero_idx 
        if state[i] == '#'
            total += real_idx
        end
        i+=1
    end
    return total
end

function process_chunk(chunk, transformations)
    for t in transformations
        if chunk == t.matcher
            return t.result
        end
    end
    return "."
end

function parse_input(input)
    offset = length("initial state: ") + 1
    initial_state = input[1][offset:end]
    transformations::Array{Transformation} = []
    for row in input[3:end-1] # last row is empty
        m = row[1:5]
        r = row[end:end]
        push!(transformations, Transformation(m, r))
    end
    return initial_state, transformations
end

struct Transformation
    matcher::String
    result::String
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        "initial state: #..#.#..##......###...###",
        "",
        "...## => #",
        "..#.. => #",
        ".#... => #",
        ".#.#. => #",
        ".#.## => #",
        ".##.. => #",
        ".#### => #",
        "#.#.# => #",
        "#.### => #",
        "##.#. => #",
        "##.## => #",
        "###.. => #",
        "###.# => #",
        "####. => #",
        ""
    ]

    println(plant_spread(input))
end

main()