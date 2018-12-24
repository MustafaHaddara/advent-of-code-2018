mutable struct Group
    team::String
    number::Int
    boost::Int
    units::Int
    health::Int
    damage::Int
    attack_type::String
    initiative::Int
    weakness::Array{String}
    immunities::Array{String}
end

Base.show(io::IO, g::Group) = print(io, "$(g.team) $(g.number) h:$(g.health) u:$(g.units) d:$(g.damage) b:$(g.boost)")

function print_g(groups::Array{Group})
    for g in groups
        println(g)
    end
end

function print_t(d)
    for (k,v) in d
        println("$k -> $v")
    end
end

function copy(g::Group)
    return Group(g.team, g.number, g.boost, g.units, g.health, g.damage, g.attack_type, g.initiative, g.weakness, g.immunities)
end

function run_immunity_battle_with_boost(input)
    groups = parse_input(input)

    boost = 0
    while true
        print("trying boost $boost: ")
        cloned::Array{Group} = []
        for g in groups
            new = copy(g)
            if new.team == "Immune System"
                new.boost = boost
            end
            push!(cloned, new)
        end

        winning = find_winning_team(cloned)
        println("winner is $winning")
        if winning == "Immune System"
            return sum(g->g.units, cloned)
        end
        # print_g(cloned)
        # return ""
        boost += 1
    end
end
    
function find_winning_team(groups)
    while battle_on(groups)
        sort!(groups, by=g->(-1*effective_power(g), -1*g.initiative))

        targets = Dict{Group, Group}()
        for g in groups
            avail_enemies = filter(other-> valid_enemy(other, g, targets), groups)

            if isempty(avail_enemies)
                continue
            end

            sort!(avail_enemies, by=e-> (-1*damage_dealt_to(g, e), -1*effective_power(e), -1*e.initiative))
            
            target = avail_enemies[1]
            if damage_dealt_to(g, target) > 0 
                targets[g] = target
            end
        end

        some_killed = false
        for g in sort(groups, by=g-> -1*g.initiative)
            if !haskey(targets, g) || g.units <= 0
                continue
            end

            target = targets[g]
            damage_dealt = damage_dealt_to(g, target)
            num_killed = Int(floor(damage_dealt / target.health))
            # println("$g attacks $target does $damage_dealt which kills $num_killed units")
            target.units -= num_killed
            if num_killed > 0
                some_killed = true
            end
        end

        # no one got killed at all
        if !some_killed
            # println("no one died")
            return "Deadlock"
        end
        # println("---")

        filter!(g->g.units > 0, groups)
    end

    return groups[1].team
end

function battle_on(groups)
    num_immune = count(g->g.team == "Immune System", groups)
    num_infection = count(g->g.team == "Infection", groups)
    return num_immune > 0 && num_infection > 0
end

function valid_enemy(e, src_group, chosen_targets)
    return e.team != src_group.team && !(e in values(chosen_targets))
end

function damage_dealt_to(src_group, target_group)
    mult = 1
    if src_group.attack_type in target_group.weakness
        # print("..target is weak")
        mult = 2
    elseif src_group.attack_type in target_group.immunities
        # print("..target is immune")
        mult = 0
    end

    damage = mult * (src_group.damage + src_group.boost)
    d = damage * src_group.units
    # println("     $src_group has $mult multiplier on $damage and with $(src_group.units) units")
    return d
end

function effective_power(g::Group)
    return g.units * (g.damage + g.boost)
end

function parse_input(input)
    groups::Array{Group} = []
    team = "Immune System"
    number = 1
    for line in input
        if line == ""
            continue
        end
        if line == "Immune System:"
            continue
        end
        if line == "Infection:"
            team = "Infection"
            number = 1
            continue
        end
        g = parse_group(line)
        g.number = number
        g.team = team
        push!(groups, g)
        number += 1
    end
    return groups
end

function parse_group(line)
    units = 0
    health = 0
    weakness = []
    immunities = []
    damage = 0
    attack_type = ""
    initiative = 0

    specials = r"\(.*\)"
    m = match(specials, line)

    if m == nothing
        specials_chunk = ""
        simplified = line
    else
        specials_chunk = m.match[2:end-1]  # remove ()
        simplified = line[1:m.offset-1] * line[m.offset+1+length(m.match):end]
    end

    tokens = split(simplified, " ")

    units = parse(Int, tokens[1])  # this is the easy one
    health = parse(Int, tokens[5])
    damage = parse(Int, tokens[13])
    attack_type = tokens[14]
    initiative = parse(Int, tokens[end])

    if specials_chunk != ""
        chunks = split(specials_chunk, "; ")
        for c in chunks
            bits = split(c, " ")

            for i in 3:length(bits)
                if endswith(bits[i], ',')
                    item = bits[i][1:end-1]
                else
                    item = bits[i]
                end

                if bits[1] == "weak"
                    push!(weakness, item)
                else
                    push!(immunities, item)
                end
            end
        end
    end

    return Group("",0,0, units, health, damage, attack_type, initiative, weakness, immunities)
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        "Immune System:",
        "17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2",
        "989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3",
        "",
        "Infection:",
        "801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning damage at initiative 1",
        "4485 units each with 2961 hit points (immune to radiation; weak to fire, cold) with an attack that does 12 slashing damage at initiative 4"
]

    println(run_immunity_battle_with_boost(input))
end

main()