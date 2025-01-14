package aoc_2024_day3

import "core:fmt"


main :: proc() {
    num1: int
    num2: int
    str1 := "1024"
    str2 := "342"

    it: int
    leng := len(str1)
    for it < leng && '0' <= str1[it] && str1[it] <= '9' {
        num2 *= 10
        num2 += int(str1[it] - '0')
        it += 1
    }
    fmt.println(num2)
}