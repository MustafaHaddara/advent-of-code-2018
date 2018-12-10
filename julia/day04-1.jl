function sleeping_time(input)
    sort!(input)

    # get minutes slept and detailed log
    guard_log = Dict{Int, Array{Int}}()
    guard_minutes_slept = Dict{Int, Int}()
    
    current_guard = nothing
    sleep_time = nothing
    for row in input
        record = parse_row(row)
        if record.event == START_SHIFT
            current_guard = record.guard_id
            if !haskey(guard_log, record.guard_id)
                guard_log[record.guard_id] = zeros(60) 
                guard_minutes_slept[record.guard_id] = 0
            end
        elseif record.event == SLEEP
            if sleep_time == nothing
                sleep_time = record.minute + 1
            end
        elseif record.event == WAKE
            if sleep_time == nothing
                println("ERROR! Got wake entry before sleep entry")
                return ""
            end
            sleep_log = guard_log[current_guard]
            for i in sleep_time:record.minute
                if sleep_log[i] == nothing
                    sleep_log[i] = 1
                else
                    sleep_log[i] += 1
                end
            end
            guard_minutes_slept[current_guard] += (record.minute - sleep_time + 1)
            sleep_time = nothing
        end
    end
    
    # find maximums
    most_minutes_slept = -1
    sleepiest_guard = -1
    most_slept_minute = -1
    for (guard_id, mins) in guard_log
        minutes_slept = guard_minutes_slept[guard_id]
        if minutes_slept > most_minutes_slept
            most_minutes_slept = minutes_slept
            sleepiest_guard = guard_id

            max_so_far = -1
            for i in 1:60
                if mins[i] > max_so_far
                    max_so_far = mins[i]
                    most_slept_minute = i-1 # julia arrays are 1-indexed!
                end
            end
        end
    end

    return sleepiest_guard * most_slept_minute
end

function parse_row(row)
    chunks = split(row, " ")
    date = chunks[1][1:end]  # omit [
    minute = split(chunks[2], ":")[2][1:end-1]  # omit ]

    guard_id = "-1"
    event = SLEEP
    if occursin("falls asleep", row)
        event = SLEEP
    elseif occursin("wakes up", row)
        event = WAKE
    else
        event = START_SHIFT
        guard_id = chunks[4][2:end]
    end

    return Entry(date, parse(Int, minute), parse(Int, guard_id), event)
end

@enum Event begin
    START_SHIFT
    SLEEP
    WAKE
end

struct Entry
    date::String
    minute::Int
    guard_id::Int
    event::Event
end

Base.show(io::IO, e::Entry) = print(io, "Entry: $(e.event) at $(e.date) $(e.minute) guard_id: $(e.guard_id)")

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")[1:end-1]  # last line is empty line
    test_input = ["[1518-11-01 00:00] Guard #10 begins shift","[1518-11-01 00:05] falls asleep","[1518-11-01 00:25] wakes up","[1518-11-01 00:30] falls asleep","[1518-11-01 00:55] wakes up","[1518-11-01 23:58] Guard #99 begins shift","[1518-11-02 00:40] falls asleep","[1518-11-02 00:50] wakes up","[1518-11-03 00:05] Guard #10 begins shift","[1518-11-03 00:24] falls asleep","[1518-11-03 00:29] wakes up","[1518-11-04 00:02] Guard #99 begins shift","[1518-11-04 00:36] falls asleep","[1518-11-04 00:46] wakes up","[1518-11-05 00:03] Guard #99 begins shift","[1518-11-05 00:45] falls asleep","[1518-11-05 00:55] wakes up"]

    println(sleeping_time(input))
end

main()