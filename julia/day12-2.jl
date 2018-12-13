function plant_spread_hardcoded(input)
    fixed = "##......##...........##.....##......##.....##........................##.....##.....##....................##...................##"

    leading_zero = num_turns - 33  # woohoo magic numbers
    return total_for(fixed, leading_zero)
end

function plant_spread_fixed(input, num_turns)
    initial_state, transformations = parse_input(input)
    fixed_state,const_offset = detect_fixed_state(initial_state, transformations)
    return total_for(fixed_state, num_turns-const_offset)
end

function detect_fixed_state(state, transformations)
    last_state = ""
    num_turns = 1
    start_idx = 1
    while last_state != state[2:end]
        last_state = state
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
            # println("checking $chunk, got $result")
            new_state *= result
        end
        state = new_state
        num_turns += 1
    end
    base = state[start_idx:end]  # first index counts for 0
    m = match(r"#", base)
    offset = num_turns - m.offset

    return base[m.offset:end], offset
end


function total_for(state, first_idx)
    i = 1
    total = 0
    while i <= length(state)
        real_idx = first_idx + i - 1
        # println("$real_idx, $(state[i])")
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

    println(plant_spread_fixed(input, 50000000000))
end

main()