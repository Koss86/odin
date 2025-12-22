package day5_2025
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Vec2 :: [2]int

main :: proc() {
    file, ok := os.read_entire_file("input")
    check_ok(ok)
    strFile := string(file)
    input := strings.split_after(strFile, "\n\n")
    ranges: [dynamic]Vec2

    for line in strings.split_lines_iterator(&input[0]) {
        if line == "" {continue}
        line := line
        buf: Vec2
        ct: int
        for n in strings.split_iterator(&line, "-") {
            num, ok := strconv.parse_int(n)
            check_ok(ok)
            if ct == 0 {
                buf.x = num
                ct += 1
            } else {
                buf.y = num
            }
        }
        append(&ranges, buf)
        buf = {}
        ct = 0
    }
    ids: [dynamic]int
    for line in strings.split_lines_iterator(&input[1]) {
        num, ok := strconv.parse_int(line)
        check_ok(ok)
        append(&ids, num)
    }
    defer {
        delete(file)
        delete(input)
        delete(ranges)
        delete(ids)
        free_all(context.temp_allocator)
    }

    sort_ranges(&ranges)
    // Combine overlapping ranges
    combined: bool
    for !combined {
        removed: int
        for i := 0; i < len(ranges); i += 1 {
            for j := 0; j < len(ranges); j += 1 {
                if i == j {continue}
                r1 := ranges[i]
                r2 := ranges[j]
                if x_within_range(r1, r2) {
                    ranges[i].x = ranges[j].x
                    ordered_remove(&ranges, j)
                    removed += 1
                } else if y_within_range(r1, r2) {
                    ranges[i].y = ranges[j].y
                    ordered_remove(&ranges, j)
                    removed += 1
                }
            }
        }
        if removed == 0 {
            combined = true
        }
    }
    // Remove ranges that are within another range
    leng := len(ranges)
    for i := 0; i < leng; i += 1 {
        r1 := ranges[i]
        for r2, j in ranges {
            if i == j {continue}
            if range_within_range(r1, r2) {
                ordered_remove(&ranges, i)
                i -= 1
                leng -= 1
                break
            }
        }
    }
    valid_ids: int
    for id in ids {
        if valid_id(id, ranges) {
            valid_ids += 1
        }
    }
    fresh_ids: int
    for range, i in ranges {
        fresh_ids += (range.y - range.x) + 1
    }
    fmt.println("Part 1 answer:", valid_ids)
    fmt.println("Part 2 answer:", fresh_ids)
}
sort_ranges :: proc(ranges: ^[dynamic]Vec2) {
    sorted: bool
    for !sorted {
        swaps: int
        for i := 0; i < len(ranges) - 1; i += 1 {
            if ranges[i].x > ranges[i + 1].x {
                tmp := ranges[i]
                ranges[i] = ranges[i + 1]
                ranges[i + 1] = tmp
                swaps += 1
            }
        }
        if swaps == 0 {
            sorted = true
        }
    }
}
range_within_range :: proc(r1: Vec2, r2: Vec2) -> bool {
    x1, y1 := r1.x, r1.y
    x2, y2 := r2.x, r2.y
    if r1.x >= r2.x && r1.y <= r2.y {
        return true
    }
    return false
}
x_within_range :: proc(r1: Vec2, r2: Vec2) -> bool {
    x1, y1 := r1.x, r1.y
    x2, y2 := r2.x, r2.y
    if x1 > x2 && x1 <= y2 && y1 > y2 {
        return true
    }
    return false
}
y_within_range :: proc(r1: Vec2, r2: Vec2) -> bool {
    x1, y1 := r1.x, r1.y
    x2, y2 := r2.x, r2.y
    if y1 < y2 && y1 >= x2 && x1 < x2 {
        return true
    }
    return false
}
valid_id :: proc(id: int, ranges: [dynamic]Vec2) -> bool {
    for range in ranges {
        if id >= range.x && id <= range.y {
            return true
        }
    }
    return false
}
check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing's not ok.", loc)
    }
}
