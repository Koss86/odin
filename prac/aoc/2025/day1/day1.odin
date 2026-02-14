package day1_2025

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

DIAL :: 99

turns :: struct {
    dir: string,
    amt: int,
}

main :: proc() {
    file, err := os.read_entire_file_from_path("input", context.allocator)
    check_err(err)
    strFile := string(file)
    Rotations: [dynamic]turns
    Lines := strings.split_lines(strFile)

    for line in Lines {
        if line != "" {
            buf: turns
            buf.dir = line[:1]
            ok: bool
            buf.amt, ok = strconv.parse_int(line[1:])
            checkOk(ok)
            append(&Rotations, buf)
        }
    }

    curPos := 50
    inc: int
    pass: int
    realPass: int
    for turn in Rotations {
        if turn.dir == "R" {
            inc = 1
        } else {
            inc = -1
        }
        for i in 0 ..< turn.amt {
            if curPos == DIAL && turn.dir == "R" || curPos == 0 && turn.dir == "L" {
                resetPos(&curPos)
            }
            curPos += inc
            if curPos == 0 {
                realPass += 1
            }
        }
        if curPos == 0 {
            pass += 1
        }
    }
    fmt.println("Part 1 answer:", pass)
    fmt.println("Part 2 answer:", realPass)
}
resetPos :: proc(pos: ^int) {
    if pos^ == DIAL {
        pos^ = -1
    } else {
        pos^ = DIAL + 1
    }
}
checkOk :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing's not ok.", loc)
    }
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.println("error:", err)
        panic("", loc)
    }
}
