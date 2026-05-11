package day09_2023

import f "core:fmt"
import "core:os"
import sc "core:strconv"
import s "core:strings"

parse_input :: proc(file: ^[]u8) -> [][]int {

    input: [dynamic][]int
    str_file := string(file^)

    for line in s.split_lines_iterator(&str_file) {

        line := line
        buf: [dynamic]int

        for num in s.split_iterator(&line, " ") {
            n, ok := sc.parse_int(num)
            check_ok(ok)
            append(&buf, n)
        }
        append(&input, buf[:])
    }

    return input[:]
}

// Create a list of diffs as described in the brief. Omitting the one with all 0's.
get_diffs :: proc(history: []int, diffs: ^[dynamic][]int, part1 := true) {

    history := history

    if all_zero(&history) do return

    dif: [dynamic]int
    l := len(history)

    if part1 {

        for i in 0 ..< l - 1 {
            n1 := history[i]
            n2 := history[i + 1]
            buf: int
            buf = n2 - n1
            append(&dif, buf)
        }

    } else {

        for i in 0 ..< l - 1 {
            n1 := history[i]
            n2 := history[i + 1]
            buf: int
            buf = n1 - n2
            append(&dif, buf)
        }
    }

    // Appending 'history' after get_diffs() calls itself.
    // This way it will get to the diff with all 0's.
    // Then collapse appending in reverse order so we can iterate
    // over it in sequence and won't have to do it backwards.

    get_diffs(dif[:], diffs, part1 = part1)
    append(diffs, history)
}

all_zero :: proc(diff: ^[]int) -> bool {
    for n in diff {
        if n != 0 {
            return false
        }
    }
    return true
}

// For part 1, total the sum of the values that would come after the end.
// For part 2, total the sum of the values that would come before the start.
sum_all_next_or_before :: proc(histories: ^[][]int, part1 := true) -> (sum: int) {

    // [arr of diff arrs][arr of diffs][nums]
    diff_lists: [dynamic][][]int

    for h in histories {
        buf: [dynamic][]int
        get_diffs(h, &buf, part1 = part1)
        append(&diff_lists, buf[:])
    }

    for diffs in diff_lists {

        n := diffs[0][0]
        diffs_len := len(diffs)

        if part1 {

            for i := 1; i < diffs_len; i += 1 {
                nums_len := len(diffs[i])
                n = n + diffs[i][nums_len - 1]
            }

        } else {

            for i := 1; i < diffs_len; i += 1 {
                n = n + diffs[i][0]
            }
        }

        sum += n
    }
    return sum
}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok do panic("Something's not ok", loc)
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        f.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
