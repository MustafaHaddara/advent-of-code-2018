function inventory_management_diff(input)
    word_idx = 0
    while word_idx < length(input)
        word_idx += 1
        word1 = input[word_idx]

        for word2 in input[word_idx+1:end]
            ch_diff = one_char_diff(word1, word2)
            if ch_diff != nothing
                return string(word1[1:ch_diff-1], word1[ch_diff+1:end])
            end
        end
    end
end

function one_char_diff(word1, word2)
    found_diff = nothing
    ch_idx = 0
    while ch_idx < length(word1)
        ch_idx += 1
        if word1[ch_idx] != word2[ch_idx]
            if found_diff == nothing
                found_diff = ch_idx
            else
                return nothing
            end
        end
    end
    return found_diff
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String))
    test_input = ["abcde","fghij","klmno","pqrst","fguij","axcye","wvxyz"]

    println(inventory_management_diff(input))
end

main()