package day13_2017

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Direction :: enum {
    Up,
    Down,
}

Scanner :: struct {
    pos:   int,
    dir:   Direction,
    depth: int,
    range: int,
}

main :: proc() {
    file, err := os.read_entire_file_from_path("input", context.allocator)
    check_err(err)
    defer delete(file)

    scanners: [dynamic]Scanner
    defer delete(scanners)
    str_file := string(file)

    for line in strings.split_lines_iterator(&str_file) {
        it: int
        line := line
        buf: Scanner
        for str in strings.split_iterator(&line, ":") {
            trimmed := strings.trim_space(str)
            switch it {
                case 0:
                    n, ok := strconv.parse_int(trimmed)
                    check_ok(ok)
                    buf.depth = n
                    it += 1
                case:
                    n, ok := strconv.parse_int(trimmed)
                    check_ok(ok)
                    buf.range = n
            }
        }
        append(&scanners, buf)
    }

    severity: int
    scnr_slc := scanners[:]
    fw_len := scanners[len(scanners) - 1].depth + 1

    for pos in 0 ..< fw_len {
        for scnr in scanners {
            if pos == scnr.depth && scnr.pos == 0 {
                severity += pos * scnr.range
            }
        }
        advance_scanners(&scnr_slc)
    }

    fmt.println("Part 1 answer:", severity)

    it := 1
    pass := false

    for !pass {
        pass = true
        for scnr in scanners {
            if (it + scnr.depth) % (2 * scnr.range - 2) == 0 {
                pass = false
                break
            }
        }
        if pass {
            fmt.println("Part 2 answer:", it)
        }
        it += 1
    }
}
advance_scanners :: proc(scanners: ^[]Scanner) {
    leng := len(scanners)
    for i in 0 ..< leng {
        inc: int
        scnr := scanners[i]

        if scnr.pos > 0 && scnr.pos < scnr.range - 1 {
            // not at start or end
            if scnr.dir == .Up {
                inc = -1
            } else {
                inc = 1
            }
        } else {
            // at start or end; flip direction
            if scnr.dir == .Up {
                inc = 1
                scanners[i].dir = .Down
            } else {
                inc = -1
                scanners[i].dir = .Up
            }
        }
        scanners[i].pos += inc
    }
}
check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Something's not ok", loc)
    }
}
check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
