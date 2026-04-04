package day15_2017

import "core:fmt"

main :: proc() {
    input := [2]int{65, 8921} // Example

    f_a := 16807
    f_b := 48271
    mod := 2147483647
    result_a, result_b: int
    total: int

    for i in 0 ..< 40_000_000 {

        if i == 0 {
            result_a = (input.x * f_a) % mod
            result_b = (input.y * f_b) % mod
        } else {
            result_a = (result_a * f_a) % mod
            result_b = (result_b * f_b) % mod
        }

        str_a := fmt.aprintf("%32b", result_a)
        str_b := fmt.aprintf("%32b", result_b)

        if str_a[16:] == str_b[16:] {
            total += 1
        }

        delete(str_a)
        delete(str_b)
    }
    fmt.println("Part 1 answer:", total)

    total = 0
    mul_a := 4
    mul_b := 8
    result_a = 0
    result_b = 0
    it_a, it_b: int
    matched: int

    for matched < 5_000_000 {
        str_a, str_b: string
        found_a, found_b: bool
        for !found_a {
            if it_a == 0 {
                result_a = (input.x * f_a) % mod
                it_a += 1
            } else {
                result_a = (result_a * f_a) % mod
            }

            if result_a % mul_a == 0 {
                str_a = fmt.aprintf("%32b", result_a)
                found_a = true
            }
        }
        for !found_b {
            if it_b == 0 {
                result_b = (input.y * f_b) % mod
                it_b += 1
            } else {
                result_b = (result_b * f_b) % mod
            }

            if result_b % mul_b == 0 {
                str_b = fmt.aprintf("%32b", result_b)
                found_b = true
            }
        }
        matched += 1
        if str_a[16:] == str_b[16:] {
            total += 1
        }
        delete(str_a)
        delete(str_b)
    }
    fmt.println("Part 2 answer:", total)
}
