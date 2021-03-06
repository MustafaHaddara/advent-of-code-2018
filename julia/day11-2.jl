function most_powerful_region(grid_num)
    max_power = nothing
    max_x = 0
    max_y = 0
    max_block_size = 0
    for block_size in 1:300
        upper_bound = 300 - block_size + 1
        for x in 1:upper_bound
            for y in 1:upper_bound
                p = power_level_block(x,y, grid_num, block_size)
                if max_power == nothing || p > max_power
                    max_power = p
                    max_x = x
                    max_y = y
                    max_block_size = block_size
                end
            end
        end
    end
    return (max_x, max_y, max_block_size)
end

function power_level_block(topx,lefty, grid_num, block_size)
    power = 0
    for x in topx:topx+(block_size-1)
        for y in lefty:lefty+(block_size-1)
            p = power_level(x,y, grid_num)
            # print("$p ")
            power += p
        end
        # println()
    end
    # println("---")
    return power
end


function power_level(x,y, grid_num)
    rack_id = x + 10
    power = rack_id * y
    power += grid_num
    power *= rack_id
    if power >= 100
        power = (power ÷ 100) % 10  # WTF: the / does float division but ÷ does integer division?!
    else
        power = 0
    end
    power -= 5
    return power
end

function main()
    input = 1309
    test_input = 42

    println(most_powerful_region(input))
end

main()