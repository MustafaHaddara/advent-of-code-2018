function conways_north_pole(input)
    board = parse_input(input)
    turns = 0

    seen = Set()
    found_base = false
    found_target = false
    period = -1
    target = 1000000000
    while turns != target
        push!(seen, stringify(board))
        turns += 1
        board = process_turn(board)
        
        new_rep = stringify(board)
        if new_rep in seen
            if !found_base
                found_base = true
                target -= turns
                seen = Set()
            elseif !found_target
                found_target = true
                period = length(seen)
                turns_to_do = target % period
                target = turns + turns_to_do
            end
        end
    end

    lumber = count_type(board, '#')
    wood = count_type(board, '|')
    println("$lumber $wood")
    return lumber * wood
end

struct Board
    tiles::Array{Array{Char}}
end

function stringify(b::Board)
    flat = []
    for row in b.tiles
        append!(flat, row)
    end
    return join(flat, "")
end

function Base.show(io::IO, b::Board)
    for row in b.tiles
        for c in row
            print(c)
        end
        println()
    end
end

function count_type(board, type)
    total = 0
    for row in board.tiles
        total += count(c -> c==type, row)
    end
    return total
end

function process_turn(board)
    new_rows = []
    for y in 1:length(board.tiles)
        new_row = []
        for x in 1:length(board.tiles[y])
            ch = get_next(board, x,y)
            push!(new_row, ch)
        end
        push!(new_rows, new_row)
    end
    return Board(new_rows)
end

function get_next(board, x,y)
    ch = board.tiles[y][x]
    surroundings = []
    minx = max(1, x-1)
    maxx = min(length(board.tiles[1]), x+1)
    miny = max(1, y-1)
    maxy = min(length(board.tiles), y+1)

    for iy in miny:maxy
        for ix in minx:maxx
            if iy == y && ix == x
                continue
            end
            push!(surroundings, board.tiles[iy][ix])
        end
    end

    # println(surroundings)
    if ch == '.'
        # open
        if count(c -> c=='|', surroundings) >= 3
            return '|'
        else
            return ch
        end
    elseif ch == '|'
        if count(c -> c=='#', surroundings) >= 3
            return '#'
        else
            return ch
        end
    else
        if any(c -> c=='|', surroundings) && any(c -> c=='#', surroundings) 
            return ch
        else
            return '.'
        end
    end
end

function parse_input(input)
    rows = []
    for line in input
        if line == ""
            break
        end
        row = []
        for ch in line
            push!(row, ch)
        end
        push!(rows, row)
    end
    return Board(rows)
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        ".#.#...|#.",
        ".....#|##|",
        ".|..|...#.",
        "..|#.....#",
        "#.#|||#|#|",
        "...#.||...",
        ".|....|...",
        "||...#|.#|",
        "|.||||..|.",
        "...#.|..|.",
    ]

    println(conways_north_pole(input))
end

main()