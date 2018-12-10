function reduction(chain)
    chain = reduction_one_pass(chain)
    return length(chain)
end

function reduction_one_pass(chain)
    result = [chain[1]]
    i = 2
    while i <= length(chain)
        a = result[end]
        b = chain[i]
        i+=1

        while a != b && uppercase(a) == uppercase(b)
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

    println(reduction(input))
end

main()