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
    nice_p1: int
    nice_p2: int
    buff, ok := os.read_entire_file(file, context.allocator)
    if !ok {
        fmt.eprintln("Unable to read file.")
        return
    }
    input := string(buff)
    for line in strings.split_lines_iterator(&input) {
        if nice_p1_pw(line) {
            nice_p1 += 1
        }
        if nice_p2_pw(line) {
            nice_p2 += 1
        }
    }
    fmt.printfln("Part 1 answer: %v", nice_p1)
    fmt.printfln("Part 2 answer: %v", nice_p2)
}

nice_p1_pw :: proc(s: string) -> bool {
    is_nice: bool
    vowel: int
    double: int
    for i in 0..<len(s)-1 {
        a := s[i]
        b := s[i+1]
        if a == b {
            double += 1
        } else if a == 'a' && b == 'b' || a == 'c' && b == 'd' ||
                  a == 'p' && b == 'q' || a == 'x' && b == 'y' {
                    is_nice = false
                    return is_nice
        }
    }
    for i in 0..<len(s) {
        c := s[i]
        if c == 'a' || c == 'e' ||
            c == 'i' || c == 'o' || c == 'u' {
                vowel += 1
            }
    }
    if vowel > 2 && double > 0 {
        is_nice = true
    }
    return is_nice
}

nice_p2_pw :: proc(s: string) -> bool {
    is_nice: bool
    pair, same_sep: int
    for i in 0..<len(s)-1 {
        a := s[i:i+2]
        if strings.count(s, a) > 1 {
            pair += 1
        }
    }
    for i in 0..<len(s)-2 {
        a := s[i]
        b := s[i+2]
        if a == b {
            same_sep += 1
        }
    }
    if pair > 0 && same_sep > 0 {
        is_nice = true
    }
    return is_nice
}