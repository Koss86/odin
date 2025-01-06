package main

import "core:fmt"

main :: proc() {
	numbers := [10]int {
		6, 4, 7, 10, 1, -1, -9, 100, 1, 54,
	}

	cmp := 6

	for n in numbers {
		if is_bigger_than(n, cmp) {
			fmt.printfln("%v is bigger than %v", n, cmp)
		}	
	}
}

is_bigger_than :: proc(number: int, compare_to: int) -> bool {
	return number > compare_to
}