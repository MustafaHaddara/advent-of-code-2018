function step_ordering(input)
    step_map = parse_input(input)
    result = alpha_bfs(step_map)

    return result
end

function alpha_bfs(step_map)
    roots = find_roots(step_map)
    result = ""
    seen = Set()
    while (!isempty(roots))
        sort!(roots)
        found = popfirst!(roots)
        result *= found

        for other in values(step_map)
            delete!(other.prev, found)
            if isempty(other.prev) && !(other.name in seen)
                push!(seen, other.name)
                push!(roots, other.name)
            end
        end
    end
    return result
end

function find_roots(step_map)
    all_nodes = Set{String}()
    for node in values(step_map)
        for prev in node.prev
            push!(all_nodes, prev)
        end
    end

    return collect(setdiff(all_nodes, keys(step_map)))
end

function parse_input(input)
    step_map = Dict{String, Step}()
    for line in input
        if line == ""
            continue
        end
        chunks = split(line)
        name = chunks[8]
        prev = chunks[2]

        if !haskey(step_map, name)
            step_map[name] = Step(name, Set())
        end
        push!(step_map[name].prev, prev)
    end

    return step_map
end

struct Step
    name::String
    prev::Set{String}
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        "Step C must be finished before step A can begin.",
        "Step C must be finished before step F can begin.",
        "Step A must be finished before step B can begin.",
        "Step A must be finished before step D can begin.",
        "Step B must be finished before step E can begin.",
        "Step D must be finished before step E can begin.",
        "Step F must be finished before step E can begin."
    ]

    println(step_ordering(input))
end

main()