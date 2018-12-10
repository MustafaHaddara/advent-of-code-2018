function chronal_calibration_repeated()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String))

    current_freq = 0
    freqs = Set([current_freq])
    while true
        for change in input
            ch = parse(Int, change)
            current_freq += ch
            if current_freq in freqs
                return current_freq
            end
            push!(freqs, current_freq)
        end
    end
end

println(chronal_calibration_repeated())
