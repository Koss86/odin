package day5
import "core:os"
import "core:fmt"
import "core:strings"

main :: proc() {
    file: string
    test := false
    if !test {
        file = "../inputs/input5.txt"
    } else {
        file = "test.txt"
    }
    valid_p1: int
    buff, ok := os.read_entire_file(file, context.allocator)
    if !ok {
        fmt.eprintfln("Unable to read file.")
        return
    }
    input := string(buff)
    for line in strings.split_lines_iterator(&input) {
        if valid_p1_pw(line) {
            valid_p1 += 1
        }
    }
    fmt.println(valid_p1)
}
valid_p1_pw :: proc(s: string) -> bool {
    is_valid: bool
    if strings.contains_any(s, "aeiou") { // any not gonna work.
        for i in 0..<len(s)-1 {
            a := s[i]
            b := s[i+1]
            if a == b {
                is_valid = true
            } else if a == 'a' && b == 'b' ||
                      a == 'c' && b == 'd' ||
                      a == 'p' && b == 'q' ||
                      a == 'x' && b == 'y' {
                            is_valid = false
                            return is_valid
            }
        }
    }
    return is_valid
}