function find_biggest_reduction(chain)
    smallest = -1

    # there's gotta be a pattern here but I can't quite figure it out
    # so we're brute forcing it
    char_A = Int("a"[1])
    for i in char_A:char_A+25
        letter = Char(i)
        sub = replace(replace(chain, letter=>""), uppercase(letter)=>"")
        reduced = reduction_one_pass(sub)
        println("$letter -> length: $(length(reduced))")
        if length(reduced) < smallest || smallest == -1
            smallest = length(reduced)
        end
    end
    return smallest
end

function reduction_one_pass(chain)
    result = [chain[1]]
    i = 2
    while i <= length(chain)
        a = result[end]
        b = chain[i]
        i+=1

        while a != b && uppercase(a) == uppercase(b) && i <= length(chain)
            deleteat!(result, length(result))  # remove a
            
            # get new a,b
            if length(result) > 0
                a = result[end]
            else
                a = ""
            end
            b = chain[i]
            i+=1
        end

        # b doesn't match last char on stack
        push!(result, b)
    end
    return join(result, "")
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")[1]
    test_input = "dabAcCaCBAcCcaDA"

    println(find_biggest_reduction(input))
end

main()