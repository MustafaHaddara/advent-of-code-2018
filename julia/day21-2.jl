function reverse_engineer(input)
    target = disassembled()

    return target
end

function disassembled()
    seen = Set()
    r0 = 0
    r1 = 0
    r2 = 0
    r3 = 0
    r5 = 0
    _last = 0

    # 7
    while true
        r2 = r3 | 65536
        r3 = 7637914

        (r1,r2,r3,r5) = line_9(r1,r2,r3,r5)
        if r3 in seen
            return _last
        else
            _last = r3
            push!(seen, r3)
        end
    end
end

function line_9(r1, r2, r3, r5)
    while true
        r1 = r2 & 255
        r3 = r3 + r1
        r3 = r3 & 16777215
        r3 = r3 * 65899
        r3 = r3 & 16777215

        if r2 <= 256
            return (r1,r2,r3,r5)  # go back to line 7
        end

        r1 = 0

        (r1,r2,r3,r5) = line_19(r1,r2,r3,r5)

        # line 27
        r2 = r1
    end
end

function line_19(r1, r2, r3, r5)
    while true
        r5 = r1 + 1
        r5 = r5 * 256
        if r5 > r2
            return (r1,r2,r3,r5)
        end
        r1 = r1 + 1
    end
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        "#ip 0",
        "seti 5 0 1",
        "seti 6 0 2",
        "addi 0 1 0",
        "addr 1 2 3",
        "setr 1 0 0",
        "seti 8 0 4",
        "seti 9 0 5"
    ]

    println(reverse_engineer(input))
end

main()