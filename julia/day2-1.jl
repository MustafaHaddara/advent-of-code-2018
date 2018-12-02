function inventory_management_checksum(input)
    hastwo = 0
    hasthree = 0

    for word in input
        two = false
        three = false
        for counts in values(find_counts(word))
            if counts == 2
                two = true
            elseif counts == 3
                three = true
            end
            if two && three
                break
            end
        end

        if two
            hastwo += 1
        end
        if three
            hasthree += 1
        end
    end

    return hastwo * hasthree
end

function find_counts(word)
    counts = Dict{Char,Integer}()
    for ch in word
        counts[ch] = get(counts, ch, 0) + 1
    end
    return counts
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String))

    println(inventory_management_checksum(input))
end

main()