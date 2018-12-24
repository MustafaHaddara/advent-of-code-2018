function reservoir_probe(input)
    board, min_y = parse_input(input)
    pump_water(board, min_y)

    return total_water(board)
end

function total_water(board)
    return count(map(
        t-> t=='~' || t=='|' || t=='/',
        board.tiles
    ))
end

mutable struct Droplet
    x::Int
    y::Int
    vx::Int
    vy::Int
end

function move!(d::Droplet, b)
    d.x += d.vx
    d.y += d.vy

    below = get(b, d.x, d.y+1)
    if below != '#' && below != '~' && below != '/'
        # drop
        d.vx = 0
        d.vy = 1
    end
end

function next(d::Droplet, b)
    return get(b, d.x+d.vx, d.y+d.vy)
end

function pump_water(board, min_y)
    counter = 1
    while true
        if pump_one_water(board, min_y)
            break
        end
    end
    # print(board)
end

function pump_one_water(board, min_y)
    d = Droplet(500,0, 0,1)
    while true
        left = get(board, d.x-1, d.y)
        right = get(board, d.x+1, d.y)
        below = get(board, d.x, d.y+1)

        n = next(d, board)

        if n == '!' || n == '|' || below == '/'
            set(board, d.x,d.y, '/')
            break
        elseif n == '#' || n == '~' || n == '/'
            # can we turn?
            if d.vx == 0
                if left != '#' && left != '/' && left != '!'
                    # go left
                    d.vx = -1
                    d.vy = 0
                elseif right != '#' && right != '/' && right != '!'
                    # go left
                    d.vx = 1
                    d.vy = 0
                else
                    set(board, d.x,d.y, '/')
                    settle_water(board, d.x, d.y)
                    break
                end
            else
                set(board, d.x,d.y, '/')
                break
            end
        end
        move!(d, board)
    end
    return (d.y <= min_y)
end

function can_settle(b, base_x, y)
    x = base_x
    # explore left
    while get(b, x,y) != '#'
        below = get(b, x,y+1)
        if below != '#' && below != '~'
            return false
        end
        x -= 1
    end
    # explore right
    x = base_x
    while get(b, x,y) != '#'
        below = get(b, x,y+1)
        if below != '#' && below != '~'
            return false
        end
        x += 1
    end
    return true
end


function settle_water(b, base_x, y)
    if can_settle(b, base_x, y)
        settle_water(b, base_x, y, '~')
    else
        settle_water(b, base_x, y, '|')
    end
end

function settle_water(b, base_x, y, ch)
    # explore left
    x = base_x
    # below = 
    while !(get(b, x,y) in ['#', '!']) && get(b, x, y+1) in ['#', '~']
        set(b, x,y, ch)
        x -= 1
    end
    # explore right
    x = base_x
    while !(get(b, x,y) in ['#', '!']) && get(b, x, y+1) in ['#', '~']
        set(b, x,y, ch)
        x += 1
    end
    return true
end

function get_next(p, v)
    return (p[1] + v[1], p[2] + v[2])
end

function find_next(loc, board)
    down = [loc[1], loc[2]+1]
    type = get(board, down...)
    if type == '.'
        return down
    end

    left = [loc[1]-1, loc[2]]
    type = get(board, left...)
    if type == '.'
        return left
    end

    right = [loc[1]+1, loc[2]]
    type = get(board, right...)
    if type == '.'
        return right
    end
end

function parse_input(input)
    sections = []
    for line in input
        if line == ""
            break
        end
        push!(sections, parse_line(line))
    end

    board = initialize_board(sections)
    set(board, 500, 0, '+')
    min_y = -1
    for s in sections
        for x in s.x_start:s.x_end
            for y in s.y_start:s.y_end
                set(board, x,y, '#')
                if y < min_y || min_y == -1
                    min_y = y
                end
            end
        end
    end

    return board, min_y
end

function parse_line(line)
    (a,b) = split(line, ", ")
    if a[1] == 'x'
        x_desc = a
        y_desc = b
    else
        x_desc = b
        y_desc = a
    end

    (x_st, x_end) = parse_chunk(x_desc)
    (y_st, y_end) = parse_chunk(y_desc)

    return Section(x_st, x_end, y_st, y_end)
end

function initialize_board(sections)
    minx = -1
    maxx = -1
    maxy = -1
    for s in sections
        if minx == -1 || s.x_start < minx
            minx = s.x_start
        end

        if maxx == -1 || s.x_end > maxx
            maxx = s.x_end
        end

        if maxy == -1 || s.y_end > maxy
            maxy = s.y_end
        end
    end

    # add a border just in case
    minx -= 1
    maxx += 1

    width = maxx - minx + 1
    offset = minx - 1

    # maxy => number of rows
    # width => number of columns
    return Board(fill('.', (maxy+1, width)), offset)
end

struct Section
    x_start::Int
    x_end::Int
    y_start::Int
    y_end::Int
end

mutable struct Board
    tiles::Array{Char, 2}
    xoffset::Int
end

function Base.show(io::IO, b::Board)
    # thousands
    print("     ")
    x = 1
    for ignore in axes(b.tiles, 2)
        digit = (b.xoffset + x) ÷ 1000
        x+=1
        print(digit)
    end
    println()

    # hundreds
    print("     ")
    x = 1
    for ignore in axes(b.tiles, 2)
        digit = ((b.xoffset + x) % 1000) ÷ 100
        x+=1
        print(digit)
    end
    println()

    # tens
    print("     ")
    x = 1
    for ignore in axes(b.tiles, 2)
        digit = ((b.xoffset + x) % 100) ÷ 10
        x+=1
        print(digit)
    end
    println()

    # ones
    print("     ")
    x = 1
    for ignore in axes(b.tiles, 2)
        tens = (b.xoffset + x) % 100
        digit = tens % 10
        x+=1
        print(digit)
    end
    println()

    y = 0
    for row in axes(b.tiles, 1)
        y<10 ? print("$y    ") : y<100 ? print("$y   ") : y<1000 ? print("$y  ") : print("$y ")
        y+=1
        for ch in b.tiles[row, :]
            print(ch)
        end
        println()
    end
end

function to_string(b::Board)
    result = ""
    for row in axes(b.tiles, 1)
        for ch in b.tiles[row, :]
            result *= ch
        end
    end
    return result
end

function get(board, p)
    return get(board, p...)
end

function get(board, x, y)
    real_y = x - board.xoffset
    real_x = y + 1
    try
        return board.tiles[real_x, real_y]
    catch BoundsError
        return '!'
    end
end

function set(board, p, value)
    set(board, p..., value)
end

function set(board, x, y, value)
    real_y = x - board.xoffset
    real_x = y + 1
    board.tiles[real_x, real_y] = value
end

function parse_chunk(chunk)
    trimmed = chunk[3:end]  # cut out the `x=`/`y=` part
    if occursin("..", trimmed)
        return map(
            c->parse(Int, c),
            split(trimmed, "..")
        )
    else
        val = parse(Int, trimmed)
        return [val, val]
    end
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        # "x=495, y=3..10",
        # "y=10, x=495..505",
        # "x=505, y=3..10",
        # "x=500, y=5",
        # "y=8, x=500..502",
        # "x=502, y=5..8",

        "x=495, y=2..7",
        "y=7, x=495..501",
        "x=501, y=3..7",
        "x=498, y=2..4",
        "x=506, y=1..2",
        "x=498, y=10..13",
        "x=504, y=10..13",
        "y=13, x=498..504"
    ]

    println(reservoir_probe(input))
end

main()