function chronal_calibration()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String))
    return mapreduce(ch->parse(Int, ch), +, input)
end

println(chronal_calibration())
