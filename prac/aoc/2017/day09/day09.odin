package day09_2017

import "core:fmt"
import "core:os"

main :: proc() {
    file, err := os.read_entire_file_from_path("input", context.allocator)
    check_err(err)
    defer delete(file)

    in_garb, skip: bool
    depth, total, garb_count: int
    for r in file {
        if skip {
            skip = false
            continue
        } else if r == '!' {
            skip = true
            continue
        }
        if !in_garb {
            switch r {
                case '<':
                    in_garb = true
                case '{':
                    depth += 1
                case '}':
                    total += depth
                    depth -= 1
            }
        } else {
            switch r {
                case '>':
                    in_garb = false
                case:
                    garb_count += 1
            }
        }
    }
    fmt.println("Part 1 answer:", total)
    fmt.println("Part 2 answer:", garb_count)
}
check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.eprintfln("error: %v", err)
        fmt.println("at:", loc)
        os.exit(1)
    }
}
