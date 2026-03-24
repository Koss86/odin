package day10_2017

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

REAL :: 256
EXAMPLE :: 5

main :: proc() {
    file, err := os.read_entire_file_from_path("input", context.allocator)
    check_err(err)
    defer delete(file)

    str_file := string(file)
    input_nums: [dynamic]int
    defer delete(input_nums)

    for num in strings.split_iterator(&str_file, ",") {
        num := strings.trim_right(num, "\n")
        n, ok := strconv.parse_int(num)
        check_ok(ok)
        append(&input_nums, n)
    }

    list: [dynamic]int
    defer delete(list)
    input_size := len(input_nums)
    list_size := make_list(input_size, &list)

    skip, cur_pos: int
    for leng in input_nums {

        end_idx: int
        reverse := true

        if leng > 1 {
            end_idx = (cur_pos + leng - 1) % list_size
        } else {
            reverse = false
        }

        if reverse {
            st := cur_pos
            end := end_idx
            if st < end {
                for _ in 0 ..< leng / 2 {
                    tmp := list[st]
                    list[st] = list[end]
                    list[end] = tmp
                    st += 1
                    end -= 1
                }
            } else {
                for _ in 0 ..< leng / 2 {
                    tmp := list[st]
                    list[st] = list[end]
                    list[end] = tmp
                    if st == list_size - 1 {
                        st = 0
                    } else {
                        st += 1
                    }
                    if end == 0 {
                        end = list_size - 1
                    } else {
                        end -= 1
                    }
                }
            }
        }

        cur_pos = (cur_pos + leng + skip) % list_size
        skip += 1
    }
    fmt.println("Part 1 answer:", list[0] * list[1])
    part_2(&file)
}
print_sequence :: proc(st, end: int, list: []int) {
    if st < end {
        for i := st; i <= end; i += 1 {
            fmt.printf("%v ", list[i])
        }
    } else {
        size := len(list)
        for i := st; i < size; i += 1 {
            fmt.printf("%v ", list[i])
        }
        for i in 0 ..= end {
            fmt.printf("%v ", list[i])
        }
    }
    fmt.println()
}
// Only really useful for Part 1 example. This will print the whole list, while
// demarcating where the start and end the the current sequence begins and ends.
print_list_example_only :: proc(st, end: int, list: []int) {
    size := len(list)
    if size > 10 {
        return
    }
    fmt.printf("[")
    for i in 0 ..< size {
        switch i {
            case st:
                fmt.printf("(\e[32m%v \e[m", list[i])
            case end:
                fmt.printf("\e[31m%v\e[m )", list[i])
            case:
                fmt.printf("%v \e[m", list[i])
        }
    }
    fmt.printfln("]")
}
make_list :: proc(input_size: int, list: ^[dynamic]int) -> int {
    list_size: int
    if input_size < 10 {
        list_size = EXAMPLE
    } else {
        list_size = REAL
    }
    for i in 0 ..< list_size {
        append(list, i)
    }
    return list_size
}
check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.eprintln("Error: %v", err)
        fmt.println("At:", loc)
        os.exit(1)
    }
}
check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Something's not ok", loc)
    }
}
