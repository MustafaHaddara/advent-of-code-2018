function reverse_engineer_more_than_3(input)
    cases = parse_input(input)

    all_ops = [
        addi,addr,
        muli,mulr,
        bani,banr,
        bori,borr,
        seti,setr,
        gtir,gtri,gtrr,
        eqir,eqri,eqrr
    ]

    matches_3 = 0
    for case in cases
        total = 0
        for op in all_ops
            if could_match(op, case)
                total += 1
            end
        end
        if total >= 3
            matches_3 += 1
        end
    end

    return matches_3
end

function could_match(op, case)
    expected = case.after
    recieved = apply_instruction(op, case)
    return expected == recieved
end

function apply_instruction(op, case)
    a,b,c = case.args
    copy_regs = [case.before...]
    op(a,b,c, copy_regs)
    return copy_regs
end

addi(a,b,c, regs) = i(add, a,b,c, regs)
addr(a,b,c, regs) = r(add, a,b,c, regs)
muli(a,b,c, regs) = i(mul, a,b,c, regs)
mulr(a,b,c, regs) = r(mul, a,b,c, regs)
bani(a,b,c, regs) = i(ban, a,b,c, regs)
banr(a,b,c, regs) = r(ban, a,b,c, regs)
bori(a,b,c, regs) = i(bor, a,b,c, regs)
borr(a,b,c, regs) = r(bor, a,b,c, regs)

function setr(a,b,c, regs)
    regs[c+1] = regs[a+1]
end
function seti(a,b,c, regs)
    regs[c+1] = a
end

function gtir(a,b,c, regs)
    if a > regs[b+1]
        regs[c+1] = 1
    else
        regs[c+1] = 0
    end
end

function gtri(a,b,c, regs)
    if regs[a+1] > b
        regs[c+1] = 1
    else
        regs[c+1] = 0
    end
end

function gtrr(a,b,c, regs)
    if regs[a+1] > regs[b+1]
        regs[c+1] = 1
    else
        regs[c+1] = 0
    end
end

function eqir(a,b,c, regs)
    if a == regs[b+1]
        regs[c+1] = 1
    else
        regs[c+1] = 0
    end
end

function eqri(a,b,c, regs)
    if regs[a+1] == b
        regs[c+1] = 1
    else
        regs[c+1] = 0
    end
end

function eqrr(a,b,c, regs)
    if regs[a+1] == regs[b+1]
        regs[c+1] = 1
    else
        regs[c+1] = 0
    end
end

add(x,y) = x+y
mul(x,y) = x*y
ban(x,y) = x&y
bor(x,y) = x|y


function r(f, a,b,c, regs)
    regs[c+1] = f(regs[a+1], regs[b+1])
end

function i(f, a,b,c, regs)
    regs[c+1] = f(regs[a+1], b)
end

function parse_input(input)
    cases = []
    idx = 1
    while idx < length(input)
        before_line = input[idx]
        instruction_line = input[idx+1]
        after_line = input[idx+2]

        if before_line == ""
            break
        end

        before_str = before_line[ length("Before: [")+1 : end-1 ]
        after_str = after_line[ length("After:  [")+1 : end-1 ]

        before = map_to_ints(before_str, ", ")
        ins = map_to_ints(instruction_line, " ")
        after = map_to_ints(after_str, ", ")

        c = Case(before, after, ins[1], ins[2:end])
        push!(cases, c)

        idx += 4
    end
    return cases
end

function map_to_ints(str, sep)
    println(str)
    return map(s->parse(Int, s), split(str, sep))
end

struct Case
    before::Array{Int}
    after::Array{Int}
    opcode::Int
    args::Array{Int}
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        "Before: [3, 2, 1, 1]",
        "9 2 1 2",
        "After:  [3, 2, 2, 1]"
    ]

    println(reverse_engineer_more_than_3(input))
end

main()