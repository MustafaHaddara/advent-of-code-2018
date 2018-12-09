function find_winning_player(input)
    num_players, final_marble_value = parse_input(input)
    marbles = Circle(0)
    points = map(c->Int(c), zeros(num_players))

    current_marble = 1
    current_player = 1

    while current_marble <= final_marble_value
        if current_marble % 23 == 0
            # do weird point stuff
            points[current_player] += current_marble
            to_remove = marbles
            for _ in 1:7
                to_remove = to_remove.prev
            end
            points[current_player] += to_remove.value
            # delete to_remove
            to_remove.prev.next = to_remove.next
            to_remove.next.prev = to_remove.prev
            marbles = to_remove.next
        else
            # insert
            one_ahead = marbles.next
            two_ahead = one_ahead.next

            next_marble = Circle(current_marble, one_ahead, two_ahead)

            one_ahead.next = next_marble
            two_ahead.prev = next_marble
            marbles = next_marble
        end
        current_marble += 1
        current_player += 1
        if current_player > num_players
            current_player = 1
        end
        # print_linked(marbles)
    end
    # print_linked(marbles)

    return maximum(points)
end

mutable struct Circle
    value::Int
    prev::Circle
    next::Circle
    function Circle(value::Int) 
        c = new()
        c.value = value
        c.prev = c
        c.next = c
        return c
    end

    Circle(value::Int, prev::Circle, next::Circle) = new(value, prev, next)
end

function print_linked(marbles)
    seen = Set{Int}()
    curr = marbles
    while curr != nothing
        if curr.value in seen
            break
        end
        push!(seen, curr.value)
        print("$(curr.value) -> ")
        curr = curr.next
    end
    println("--")
end

function parse_input(input)
    chunks = split(input, " ")
    num_players = parse(Int, chunks[1])
    point_value = 100*parse(Int, chunks[7])
    return (num_players, point_value)
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")[1]
    test_input = "10 players; last marble is worth 1618 points"

    println(find_winning_player(input))
end

main()