function goblins_vs_elves(input)
    board = parse_input(input)

    println("Round: 0")
    print_board(board)
    num_rounds = 0
    while game_is_running(board)
        # do stuff
        sort!(board.fighters, by = f-> (f.y, f.x))

        num_rounds += game_loop(board)

        filter!(f->f.hp>0, board.fighters)

        println("Round: $num_rounds")
        print_board(board)
        # num_rounds += 1
    end

    trh = sum(f -> f.hp, board.fighters)
    println("$num_rounds, $trh")
    return num_rounds * trh
end

function game_loop(board)
    for fighter in board.fighters
        if !game_is_running(board)
            return 0
        end
        if fighter.hp <= 0
            continue
        end
        enemies = filter(f-> (f.role != fighter.role && f.hp>0), board.fighters)
        adjacent_enemy = get_adjacent_enemy(fighter, enemies)
        if adjacent_enemy != nothing
            ## attack
            adjacent_enemy.hp -= fighter.ap
        else
            ## move
            paths_to = Dict()
            for e in enemies
                paths_to[e] = build_paths_to_dest( (fighter.x, fighter.y), (e.x, e.y), board)
            end
            move_to_best(fighter, paths_to)
            
            adjacent_enemy = get_adjacent_enemy(fighter, enemies)
            if adjacent_enemy != nothing
                ## attack
                adjacent_enemy.hp -= fighter.ap
            end
        end
    end
    return 1
end

function game_is_running(board)
    has_goblins = any(f -> f.role == 'G' && f.hp > 0, board.fighters)
    has_elves = any(f -> f.role == 'E' && f.hp > 0, board.fighters)
    return has_goblins && has_elves
end

function move_to_best(fighter, paths_to)
    shortest_path = -1
    target = nothing
    targets = sort(
                filter(
                    f -> f.role != fighter.role,
                    collect(keys(paths_to))
                ),
                by=f->(f.y, f.x)
            )
    for t in targets
        path_length = get_path_length(fighter, paths_to[t])
        if path_length != -1 && (shortest_path == -1 || path_length < shortest_path)
            target = t
            shortest_path = path_length
        end
    end

    if target == nothing
        return
    end

    # now we know which fighter we're targeting
    # let's actually move there
    next_loc = paths_to[target][(fighter.x, fighter.y)]
    fighter.x = next_loc[1]
    fighter.y = next_loc[2]
end

function get_path_length(fighter, paths)
    pl = 0
    loc = (fighter.x, fighter.y)
    if !haskey(paths, loc)
        return -1
    end
    while paths[loc] != nothing
        loc = paths[loc]
        pl += 1
    end
    return pl
end

function build_paths_to_dest(src, dst, board)
    paths = Dict()
    paths[dst] = nothing

    frontier = [dst]
    while !isempty(frontier)
        current = pop!(frontier)  # remove from end

        # this ordering is intentional
        # this means we build the paths in reading order where possible
        neighbors = [
            (current[1], current[2]-1),
            (current[1]-1, current[2]),
            (current[1]+1, current[2]),
            (current[1], current[2]+1)
        ]
        for next in neighbors
            if next[1] == src[1] && next[2] == src[2]
                paths[next] = current
                empty!(frontier)  # we found what we need
                break
            end
            tile = board.tiles[next[2]][next[1]]
            # println("\texploring $next -> $tile")
            # println("\t\t$(tile == '#')")
            # println("\t\t$(any(f -> f.x==next[1] && f.y==next[2], board.fighters))")
            if tile == '#' ||
                any(f -> f.hp>0 && f.x==next[1] && f.y==next[2], board.fighters)
                continue
            end
            if !haskey(paths, next)
                # println("found new square $next")
                paths[next] = current
                pushfirst!(frontier, next)  # push it at the beginning -- mock out a queue
            end
        end
    end

    return paths
end

function squares_with_no_enemies(squares, fighters)
    taken = Set(map(f -> (f.x,f.y), fighters))
    return filter(s-> !(s in taken), squares)
end

function get_adjacent_enemy(fighter, enemies)
    candidate_pos = [
        (fighter.x, fighter.y-1),
        (fighter.x-1, fighter.y),
        (fighter.x+1, fighter.y),
        (fighter.x, fighter.y+1)
    ]
    es = []
    min_health = -1
    for p in candidate_pos
        for e in enemies
            if p[1] == e.x && p[2] == e.y
                push!(es, e)
                if min_health == -1 || e.hp < min_health
                    min_health = e.hp
                end
            end
        end
    end
    if isempty(es)
        return nothing
    end
    filter!(e -> e.hp == min_health, es)
    # sort!(es, by = e-> (e.y, e.x))
    # println("$fighter -> $es")
    return es[1]
end

function get_adjacent_squares(enemies, board)
    squares = Set()
    for e in enemies
        candidate_pos = [
            (e.x+1, e.y),
            (e.x-1, e.y),
            (e.x, e.y+1),
            (e.x, e.y-1)
        ]
        for p in candidate_pos
            try
                if board.tiles[p[2]][p[1]] == '.'
                    push!(squares, p)
                end
            catch BoundsError
                # ignore it
                continue
            end
        end
    end
    return squares
end

function parse_input(input)
    rows::Array{Array{Char}} = []
    fighters::Array{Fighter} = []
    y = 0
    for line in input
        y += 1
        row::Array{Char} = []
        x = 0
        for ch in line
            x+=1
            if ch == 'G' || ch == 'E'
                push!(fighters, Fighter(x,y, ch))
                push!(row, '.')
            else
                push!(row, ch)
            end
        end
        push!(rows, row)
    end
    return Board(rows, fighters)
end

mutable struct Fighter
    x::Int
    y::Int
    role::Char
    hp::Int
    ap::Int
end

Fighter(x,y, role) = Fighter(x,y, role, 200, 3)

struct Board
    tiles::Array{Array{Char}}
    fighters::Array{Fighter}
end

function print_board(board::Board)
    sort!(board.fighters, by = f-> (f.y, f.x))
    # println("vvv")
    fighter_idx = 1
    y = 1
    for row in board.tiles
        x = 1
        for ch in row
            if fighter_idx <= length(board.fighters)
                fighter = board.fighters[fighter_idx]
                if fighter.x == x && fighter.y == y
                    print(fighter.role)
                    fighter_idx += 1
                    x += 1
                    continue
                end
            end
            print(ch)
            x += 1
        end
        println()
        y += 1
    end
    # println(board.fighters)
    # println("^^^")
    println()
    println()
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        "#######",
        "#G..#E#",
        "#E#E.E#",
        "#G.##.#",
        "#...#E#",
        "#...E.#",
        "#######"
    ]
    test_input2 = [
        "#######",
        "#E..EG#",
        "#.#G.E#",
        "#E.##E#",
        "#G..#.#",
        "#..E#.#",
        "#######"
    ]
    test_input3 = [
        "#######",
        "#E.G#.#",
        "#.#G..#",
        "#G.#.G#",
        "#G..#.#",
        "#...E.#",
        "#######"
    ]
    test_input4 = [
        "#########",
        "#G......#",
        "#.E.#...#",
        "#..##..G#",
        "#...##..#",
        "#...#...#",
        "#.G...G.#",
        "#.....G.#",
        "#########"
    ]
    test_input5 = [
        "#######",
        "#.G...#",
        "#...EG#",
        "#.#.#G#",
        "#..G#E#",
        "#.....#",
        "#######"
    ]

    println(goblins_vs_elves(input))
end

main()