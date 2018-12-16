function reverse_engineer(input)
    cases, prog = parse_input(input)

    mapping = find_opcode_mapping(cases)

    return execute(prog, mapping)
end

function execute(program, mapping)
    regs = [0, 0, 0, 0]

    for instruction in program
        execute_instruction!(regs, instruction, mapping)
    end

    return regs
end

function execute_instruction!(regs, instruction, mapping)
    a,b,c = instruction.args
    f = mapping[instruction.opcode]
    f(a,b,c, regs)
end

function find_opcode_mapping(cases)
    all_ops = [
        addi,addr,
        muli,mulr,
        bani,banr,
        bori,borr,
        seti,setr,
        gtir,gtri,gtrr,
        eqir,eqri,eqrr
    ]

    possibilities = Dict()
    for case in cases
        p = Set()
        for op in all_ops
            if could_match(op, case)
                push!(p, op)
            end
        end

        opcode = case.opcode
        if !haskey(possibilities, opcode)
            possibilities[opcode] = p
        else
            intersect!(possibilities[opcode], p)
        end
    end

    while any(p->length(p) > 1, values(possibilities))
        for (opcode,funcs) in possibilities
            if length(funcs) == 1
                # remove it from all the other cases
                for (o,f) in possibilities
                    if o == opcode
                        continue
                    end
                    setdiff!(f, funcs)  # subtract funcs from f
                end
            end
        end
    end

    mapping = Dict()
    for (opcode, set) in possibilities
        mapping[opcode] = pop!(set) #get one item out
    end
    return mapping
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

    prog = []
    idx += 1
    while idx < length(input)
        line = input[idx]
        idx += 1
        if line == ""
            continue
        end

        ints = map_to_ints(line, " ")
        instruction = Instruction(ints[1], ints[2:end])
        push!(prog, instruction)
    end
    return (cases, prog)
end

function map_to_ints(str, sep)
    return map(s->parse(Int, s), split(str, sep))
end

struct Instruction
    opcode::Int
    args::Array{Int}
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

    println(reverse_engineer(input))
end

main()