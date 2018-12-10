function sky_letter(input)
    stars::Array{Star} = []
    for line in input
        if line != ""
            push!(stars, parse_input(line))
        end
    end

    step_count = 0
    last_xrange = -1
    last_yrange = -1
    while true
        step_count += 1
        for star in stars
            star.x += star.v_x
            star.y += star.v_y
        end

        minx,miny, maxx,maxy = find_bounds(stars)
        xrange = maxx - minx + 1 
        yrange = maxy - miny + 1 

        if last_yrange == -1
            last_xrange = xrange
            last_yrange = yrange
        else
            if xrange > last_xrange
                # rewind one step
                for star in stars
                    star.x -= star.v_x
                    star.y -= star.v_y
                end
                print_stars(stars)
                return step_count-1
            end
            last_xrange = xrange
            last_yrange = yrange
        end
    end
end

function print_stars(stars)
    PADDING = 2
    minx,miny, maxx,maxy = find_bounds(stars)
    xrange = maxx - minx + 1 +(2*PADDING)
    yrange = maxy - miny + 1 +(2*PADDING)
    grid = fill(".", yrange, xrange)
    for star in stars
        grid[star.y-miny+1+PADDING, star.x-minx+1+PADDING] = "#"
    end
    for y in 1:yrange
        for x in 1:xrange
            print(grid[y, x])
        end
        println()
    end
end

function find_bounds(stars)
    minx = stars[1].x
    miny = stars[1].y
    maxx = stars[1].x
    maxy = stars[1].y
    for star in stars[2:end]
        if star.x < minx
            minx = star.x
        end
        if star.y < miny
            miny = star.y
        end
        if star.x > maxx
            maxx = star.x
        end
        if star.y > maxy
            maxy = star.y
        end
    end
    return (minx,miny, maxx,maxy)
end

function parse_input(line)
    # too lazy to figure out capture groups in julia regex
    x = ""
    y = ""
    v_x = ""
    v_y = ""
    i = length("position=<") + 1

    while line[i] != ','
        x *= line[i]
        i+=1
    end
    i+=1

    while line[i] != '>'
        y *= line[i]
        i+=1
    end
    i+=length(" velocity=<") + 1

    while line[i] != ','
        v_x *= line[i]
        i+=1
    end
    i+=1

    while line[i] != '>'
        v_y *= line[i]
        i+=1
    end
    return Star(parse(Int,x),parse(Int,y), parse(Int,v_x),parse(Int,v_y))
end

mutable struct Star
    x::Int
    y::Int
    v_x::Int
    v_y::Int
end

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")
    test_input = [
        "position=< 9,  1> velocity=< 0,  2>",
        "position=< 7,  0> velocity=<-1,  0>",
        "position=< 3, -2> velocity=<-1,  1>",
        "position=< 6, 10> velocity=<-2, -1>",
        "position=< 2, -4> velocity=< 2,  2>",
        "position=<-6, 10> velocity=< 2, -2>",
        "position=< 1,  8> velocity=< 1, -1>",
        "position=< 1,  7> velocity=< 1,  0>",
        "position=<-3, 11> velocity=< 1, -2>",
        "position=< 7,  6> velocity=<-1, -1>",
        "position=<-2,  3> velocity=< 1,  0>",
        "position=<-4,  3> velocity=< 2,  0>",
        "position=<10, -3> velocity=<-1,  1>",
        "position=< 5, 11> velocity=< 1, -2>",
        "position=< 4,  7> velocity=< 0, -1>",
        "position=< 8, -2> velocity=< 0,  1>",
        "position=<15,  0> velocity=<-2,  0>",
        "position=< 1,  6> velocity=< 1,  0>",
        "position=< 8,  9> velocity=< 0, -1>",
        "position=< 3,  3> velocity=<-1,  1>",
        "position=< 0,  5> velocity=< 0, -1>",
        "position=<-2,  2> velocity=< 2,  0>",
        "position=< 5, -2> velocity=< 1,  2>",
        "position=< 1,  4> velocity=< 2,  1>",
        "position=<-2,  7> velocity=< 2, -2>",
        "position=< 3,  6> velocity=<-1, -1>",
        "position=< 5,  0> velocity=< 1,  0>",
        "position=<-6,  0> velocity=< 2,  0>",
        "position=< 5,  9> velocity=< 1, -2>",
        "position=<14,  7> velocity=<-2,  0>",
        "position=<-3,  6> velocity=< 2, -1>"
    ]

    println(sky_letter(input))
end

main()