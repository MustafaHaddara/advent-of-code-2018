function find_winning_player(input)
    num_players, final_marble_value = parse_input(input)
    marbles = []
    points = map(c->Int(c), zeros(num_players))

    current_marble = 0
    current_marble_position = 0
    current_player = 1

    while current_marble <= final_marble_value
        if length(marbles) == 0
            push!(marbles, current_marble)
            current_marble_position = 1
            current_marble += 1
            continue  # this doesn't count as a turn
        else
            if current_marble % 23 == 0
                # do weird point stuff
                points[current_player] += current_marble
                to_remove = current_marble_position - 7
                if to_remove < 1
                    to_remove = length(marbles) + to_remove
                end
                points[current_player] += splice!(marbles, to_remove)
                current_marble_position = to_remove
            else
                next_marble_location = (current_marble_position + 2)
                if next_marble_location > length(marbles) + 1
                    next_marble_location = 2
                end
                insert!(marbles, next_marble_location, current_marble)
                current_marble_position = next_marble_location
            end
        end
        current_marble += 1
        current_player += 1
        if current_player > num_players
            current_player = 1
        end
    end

    return maximum(points)
end

function parse_input(input)
    chunks = split(input, " ")
    num_players = parse(Int, chunks[1])
    point_value = parse(Int, chunks[7])
    return (num_players, point_value)
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")[1]
    test_input = "10 players; last marble is worth 1618 points"

    println(find_winning_player(input))
end

main()