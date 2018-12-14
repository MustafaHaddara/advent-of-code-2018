function mine_cart_crash(input)
    board = parse_input(input)

    while true
        c = tick(board)
        if c != nothing
            return c
        end
    end
    return ""
end

function tick(board)
    # print_board(board)
    sort!(board.carts, by=c -> (c.y, c.x))
    for cart in board.carts
        move(cart, board)
        c = check_collisions(board.carts)
        if c != nothing
            return c
        end
    end
    return nothing
end

function check_collisions(carts)
    positions = Set()
    for cart in carts
        pos = (cart.x, cart.y)
        if pos in positions
            return pos
        else
            push!(positions, pos)
        end
    end
    return nothing
end

function move(cart, board)
    update_position(cart)
    track = board.tracks[cart.y+1][cart.x+1]
    if track == '/' || track == '\\'
        turn(cart, track)
    elseif track == '+'
        increment_next_turn(cart)
    end
end

function turn(cart, track)
    if (cart.v == '^' && track == '/') ||
        (cart.v == '>' && track == '\\') ||
        (cart.v == 'v' && track == '/') ||
        (cart.v == '<' && track == '\\')
            direction = 'R'
    else
            direction = 'L'
    end
    rotate(cart, direction)
end

function rotate(cart, direction)
    if direction == 'L'
        if cart.v == '<'
            cart.v = 'v'
        elseif cart.v == 'v'
            cart.v = '>'
        elseif cart.v == '>'
            cart.v = '^'
        elseif cart.v == '^'
            cart.v = '<'
        end
    elseif direction == 'R'
        if cart.v == '<'
            cart.v = '^'
        elseif cart.v == '^'
            cart.v = '>'
        elseif cart.v == '>'
            cart.v = 'v'
        elseif cart.v == 'v'
            cart.v = '<'
        end
    end
end

function update_position(cart)
    if cart.v == '>'
        cart.x += 1
    elseif cart.v == '<'
        cart.x -= 1
    elseif cart.v == 'v'
        cart.y += 1
    elseif cart.v == '^'
        cart.y -= 1
    end
end

function increment_next_turn(cart)
    if cart.next_turn == 'L'
        rotate(cart, cart.next_turn)
        cart.next_turn = 'S'
    elseif cart.next_turn == 'R'
        rotate(cart, cart.next_turn)
        cart.next_turn = 'L'
    else
        cart.next_turn = 'R'
    end
end

function print_board(board)
    for row in board.tracks
        for ch in row
            print(ch)
        end
        println()
    end
    println(board.carts)
end

function parse_input(input)
    rows::Array{Array{Char}} = []
    carts::Array{Cart} = []
    
    y = -1
    for row in input
        y += 1
        x = -1
        tracks::Array{Char} = []
        for ch in row
            x += 1
            if ch == ' ' || ch == '|' || ch == '-' || ch == '/' || ch == '\\' || ch == '+'
                push!(tracks, ch)
            elseif ch == '>' || ch == '<'
                push!(tracks, '-')
                push!(carts, Cart(x, y, ch, 'L'))
            elseif ch == 'v' || ch == '^'
                push!(tracks, '|')
                push!(carts, Cart(x, y, ch, 'L'))
            end
        end
        push!(rows, tracks)
    end

    return Board(rows, carts)
end

mutable struct Cart
    x::Int
    y::Int
    v::Char
    next_turn::Char
end

mutable struct Board
    tracks::Array{Array{Char}}
    carts::Array{Cart}
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
"/->-\\        ",
"|   |  /----\\",
"| /-+--+-\\  |",
"| | |  | v  |",
"\\-+-/  \\-+--/",
"  \\------/  ",
    ]

    println(mine_cart_crash(input))
end

main()