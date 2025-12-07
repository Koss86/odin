package day2_2025
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Ranges :: struct {
    range: [dynamic]string,
}

main :: proc() {

    file, ok := os.read_entire_file("input")
    checkOk(ok)
    strFile := string(file)
    idRanges: [dynamic]Ranges

    for str in strings.split_iterator(&strFile, ",") {
        str := str
        strBuf: Ranges
        for range in strings.split_iterator(&str, "-") {
            append(&strBuf.range, range)
        }
        append(&idRanges, strBuf)
    }
    defer {
        for id in idRanges {
            delete(id.range)
        }
        delete(file)
        delete(idRanges)
    }

    invalid1, invalid2: int
    for id in idRanges {
        st, end: int
        st, ok = strconv.parse_int(id.range[0])
        checkOk(ok)
        end, ok = strconv.parse_int(id.range[1])
        checkOk(ok)

        for i := st; i <= end; i += 1 {
            if i < 10 {
                continue
            }
            strBuilder := strings.builder_make(context.temp_allocator)
            strings.write_int(&strBuilder, i)
            str := strings.to_string(strBuilder)
            if invalidP1(str) {
                invalid1 += i
                invalid2 += i
            } else {
                if len(str) > 2 && invalidP2(str) {
                    invalid2 += i
                }
            }
            free_all(context.temp_allocator)
        }
    }
    fmt.println("Part 1 answer:", invalid1)
    fmt.println("Part 2 answer:", invalid2)
}
invalidP1 :: proc(str: string) -> bool {
    mid := len(str) / 2
    s1 := str[:mid]
    s2 := str[mid:]
    if s1 == s2 {
        return true
    }
    return false
}
invalidP2 :: proc(str: string) -> bool {
    if len(str) == 3 {
        r1, r2, r3: u8
        r1 = str[0]
        r2 = str[1]
        r3 = str[2]
        if r1 == r2 && r2 == r3 {
            return true
        }
    } else {
        for i := 0; i <= len(str) / 2; i += 1 {
            left := str[:i + 1]
            right := str[i + 1:]
            n := strings.count(right, left)

            if len(left) * n == len(right) {
                return true
            }
        }
    }
    return false
}
checkOk :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing's not ok", loc)
    }
}