function overlapping_squares(input)
    rects = parse_rects(input)

    # sort the array by left position
    sort!(rects, by=r->r.left)

    already_seen = Set()
    idx = 0
    while idx < length(rects)
        idx += 1
        if check_for_overlaps!(already_seen, rects, idx)
            rect = rects[idx]
            if rect in already_seen
                continue
            end
            return rect.id
        end
    end
end

function check_for_overlaps!(already_seen, rects, idx)
    base = rects[idx]

    other_idx = idx

    has_overlap = false
    while other_idx < length(rects)
        other_idx += 1
        other = rects[other_idx]

        if beyond_x(base, other)
            # they don't overlap and nothing further will overlap
            # because it's sorted by x
            break
        end

        if !overlaps_y(base, other)
            # they don't overlap but there might be a later rect that does overlap
            continue
        end

        has_overlap = true
        push!(already_seen, other)
        push!(already_seen, base)
    end
    return !has_overlap
end

function get_points(r)
    points = Set()
    for x in r.left:r.left+r.width-1
        for y in r.top:r.top+r.height-1
            push!(points, Point(x, y))
        end
    end
    return points
end

function beyond_x(base, other)
    return base.left + base.width <= other.left
end

function overlaps_y(base, other)
    if base.top > other.top
        return other.top + other.height > base.top
    else
        return base.top + base.height > other.top
    end
end

function parse_rects(input)
    rects = []
    for claim in input
        r = parse_rect(claim)
        push!(rects, r)
    end
    return rects
end

function parse_rect(line)
    chunks = split(line, " ")
    id = parse(Int, chunks[1][2:end])  # remove the #

    corner = split(chunks[3], ",")
    left = parse(Int, corner[1])
    top = parse(Int, corner[2][1:end-1])  # remove the ,

    span = split(chunks[4], "x")
    width = parse(Int, span[1])
    height = parse(Int, span[2])

    return Rect(id, left, top, width, height)
end

struct Rect
    id::Int
    left::Int
    top::Int
    width::Int
    height::Int
end

Base.show(io::IO, r::Rect) = print(io, "Rect Id #$(r.id) at $(r.left),$(r.top) with w=$(r.width) and h=$(r.height)")

function main()
    filename = ARGS[1]  # julia arrays are 1-indexed!
    input = split(read(filename, String), "\n")[1:end-1]  # last line is empty line
    test_input = ["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"]

    println(overlapping_squares(input))
end

main()