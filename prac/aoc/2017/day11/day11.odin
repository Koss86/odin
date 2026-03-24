package day11_2017

import "core:fmt"
import "core:os"
import "core:strings"

Vec3 :: [3]int

N :: Vec3{0, 1, -1}
S :: Vec3{0, -1, 1}
NW :: Vec3{-1, 1, 0}
SW :: Vec3{-1, 0, 1}
NE :: Vec3{1, 0, -1}
SE :: Vec3{1, -1, 0}

Dir :: enum {
    n, s, nw, sw, ne, se,
}

main :: proc() {
    file, err := os.read_entire_file_from_path("input", context.allocator)
    check_err(err)
    defer delete(file)

    str_file := string(file)
    dirs: [dynamic]Dir
    defer delete(dirs)

    for str in strings.split_iterator(&str_file, ",") {
        trimmed := strings.trim_right(str, "\n")
        switch trimmed {
            case "n":
                append(&dirs, Dir.n)
            case "s":
                append(&dirs, Dir.s)
            case "nw":
                append(&dirs, Dir.nw)
            case "sw":
                append(&dirs, Dir.sw)
            case "ne":
                append(&dirs, Dir.ne)
            case "se":
                append(&dirs, Dir.se)
        }
    }

    cur_pos: Vec3
    highest: int

    for dir in dirs {
        switch dir {
            case .n:
                cur_pos += N
            case .s:
                cur_pos += S
            case .nw:
                cur_pos += NW
            case .sw:
                cur_pos += SW
            case .ne:
                cur_pos += NE
            case .se:
                cur_pos += SE
        }
        dist := distance(cur_pos)
        if dist > highest {
            highest = dist
        }
    }

    fmt.println("Part 1 answer:", distance(cur_pos))
    fmt.println("Part 2 answer:", highest)
}

distance :: proc(pos: Vec3) -> int {
    dx := abs(pos.x)
    dy := abs(pos.y)
    dz := abs(pos.z)
    return max(dx, dy, dz)
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.eprintln("Error: %v", err)
        fmt.println("At:", loc)
        os.exit(1)
    }
}
