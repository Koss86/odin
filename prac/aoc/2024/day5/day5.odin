package day5_2024
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

int2 :: [2]int

main :: proc() {
    input: [dynamic]string
    file, ok := os.read_entire_file("input")
    checkOk(ok)
    file_str := string(file)
    for line in strings.split_iterator(&file_str, "\n\n") {
        append(&input, line)
    }
    rulesStr := strings.split_lines(input[0])
    pagesStr := strings.split_lines(input[1])
    rules: [dynamic]int2
    pages: [dynamic][dynamic]int

    for i in 0 ..< len(rulesStr) {
        buf: int2
        tmp: int
        ct: int
        for str in strings.split_iterator(&rulesStr[i], "|") {
            tmp, ok := strconv.parse_int(str)
            checkOk(ok)
            switch ct {
                case 0:
                    buf.x = tmp
                    ct += 1
                case 1:
                    buf.y = tmp
                    ct = 0
                    append(&rules, buf)
            }
        }
    }
    for i in 0 ..< len(pagesStr) - 1 {
        buf: [dynamic]int
        strBuf := pagesStr[i]
        for str in strings.split_iterator(&strBuf, ",") {
            tmp, ok := strconv.parse_int(str)
            checkOk(ok)
            append(&buf, tmp)
        }
        append(&pages, buf)
    }
    defer {
        for arr in pages {
            delete(arr)
        }
        delete(file)
        delete(input)
        delete(rules)
        delete(pages)
        delete(rulesStr)
        delete(pagesStr)
        free_all(context.temp_allocator)
    }

    total1: int
    total2: int
    for i in 0 ..< len(pages) {
        if validPage(&rules, pages[i]) {
            tmp := len(pages[i]) - 1
            tmp = tmp / 2
            total1 += pages[i][tmp]
        } else {
            for !validPage(&rules, pages[i]) {
                makeValid(&rules, pages[i])
            }
            tmp := len(pages[i]) - 1
            tmp = tmp / 2
            total2 += pages[i][tmp]
        }
    }
    fmt.println("Part 1 answer:", total1)
    fmt.println("Partt 2 answer:", total2)
}
makeValid :: proc(rules: ^[dynamic]int2, page: [dynamic]int) {
    for i in 0 ..< len(rules) {
        found: bool
        indx1: int
        indx1, found = slice.linear_search(page[:], rules[i].x)
        if found {
            indx2: int
            indx2, found = slice.linear_search_reverse(page[:], rules[i].y)
            if found {
                if indx1 > indx2 {
                    tmp := page[indx1]
                    page[indx1] = page[indx2]
                    page[indx2] = tmp
                }
            }
        }
    }
}
validPage :: proc(rules: ^[dynamic]int2, page: [dynamic]int) -> bool {
    for i in 0 ..< len(rules) {
        found: bool
        indx1: int
        indx1, found = slice.linear_search(page[:], rules[i].x)
        if found {
            indx2: int
            indx2, found = slice.linear_search_reverse(page[:], rules[i].y)
            if found {
                if indx1 > indx2 {
                    return false
                }
            }
        }
    }
    return true
}
checkOk :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Something wasn't ok.", loc)
    }
}
