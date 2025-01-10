package dynamic_array_example

import "core:fmt"

main :: proc() {
	dyn_arr: [dynamic]int

	// Will make `dyn_arr` grow:
	append(&dyn_arr, 5)
	
	fmt.println("After first append:")
	fmt.println("Capacity:", cap(dyn_arr)) // 8
	fmt.println("Length:", len(dyn_arr)) // 1

	// append 7 numbers to the dynamic
	// array. This will not make `dyn_arr`
	// grow since capacity is `8` after
	// first `append`.
	for i in 0..<7 {
		append(&dyn_arr, i)
	}

	fmt.println("\nAfter 7 more appends:")
	fmt.println("Capacity:", cap(dyn_arr)) // 8
	fmt.println("Length:", len(dyn_arr)) // 8

	// Capacity is 8, length is 8. This
	// call to `append` will make `dyn_arr`
	// grow:
	append(&dyn_arr, 5)

	fmt.println("\nAfter one more append:")
	fmt.println("Capacity:", cap(dyn_arr)) // 24
	fmt.println("Length:", len(dyn_arr)) // 9
}