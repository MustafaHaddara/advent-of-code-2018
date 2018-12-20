function reverse_engineer(input)
    (ip, prog) = parse_input(input)
    mapping = get_opcode_mapping()

    return execute(ip, prog, mapping)
end

function execute(ip_reg, program, mapping)
    regs = [0, 0, 0, 0, 0, 0]

    ip = 0
    while ip < length(program)
        next_instruction = program[ip + 1]

        regs[ip_reg + 1] = ip
        execute_instruction!(regs, next_instruction, mapping)

        ip = regs[ip_reg + 1]
        ip += 1  # move to the next instruction
    end

    return regs
end

function execute_instruction!(regs, instruction, mapping)
    a,b,c = instruction.args
    f = mapping[instruction.opcode]
    f(a,b,c, regs)
end

function get_opcode_mapping()
    all_ops = [
        addi,addr,
        muli,mulr,
        bani,banr,
        bori,borr,
        seti,setr,
        gtir,gtri,gtrr,
        eqir,eqri,eqrr
    ]

    mapping = Dict()
    for op in all_ops
        mapping[string(op)] = op
    end

    return mapping
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
    prog = []
    ip = -1
    idx = 1
    while idx <= length(input)
        line = input[idx]
        idx += 1
        if line == ""
            continue
        end

        chunks = split(line, " ")
        opcode = chunks[1]
        ints = map_to_ints(chunks[2:end])
        if opcode == "#ip"
            ip = ints[1]
        else
            instruction = Instruction(opcode, ints)
            push!(prog, instruction)
        end
    end
    return (ip, prog)
end

function map_to_ints(chunks)
    return map(s->parse(Int, s), chunks)
end

struct Instruction
    opcode::String
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