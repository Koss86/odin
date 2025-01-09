package aoc_2024_day1

import "core:os"
import "core:fmt"
import "core:slice"
import "core:sort"
import "core:strings"
import "core:strconv"

SIZE :: 1000
LEN :: 5

loc_str_struc :: struct {
	loc1: string,
	loc2: string,
}

main :: proc() {

	file := "input.txt"
    data, ok := os.read_entire_file(file, context.allocator)
	if !ok {

		fmt.println("Error reading input.")
		return
	}
	defer delete(data, context.allocator)

	indx: int
	locations_str: [SIZE] loc_str_struc
	it := string(data)

	for line in strings.split_lines_iterator(&it) {

		if !ok {

		fmt.println("Error in split_lines_iterator")
		}
		ns := line
		splits := [?]string {"   "}
		count: int
		for str in strings.split_multi_iterate(&ns, splits[:]) {

			if !ok {

				fmt.println("Error in split_multi_iterate")
			}
			if count == 0 {

				locations_str[indx].loc1 = str
				count += 1
			} else {

				//fmt.printfln("indx is %v", indx)
				locations_str[indx].loc2 = str
				count = 0
				indx += 1
			}
		}
	}
	l_list: [SIZE] int
	r_list: [SIZE] int
	for i in 0..<SIZE {

		tmp:= locations_str[i].loc1
		l_list[i] = strconv.atoi(tmp)

		tmp = locations_str[i].loc2
		r_list[i] = strconv.atoi(tmp)
	}
	slice.sort(l_list[:])
	slice.sort(r_list[:])
	a, b: int
	sum, total: int
	for i in 0..<SIZE {

		a = l_list[i]
		b = r_list[i]

		if a < b {

			sum = b - a
			fmt.printfln("b(%v) - a(%v) = %v", b, a, b-a)
			
		} else {

			sum = a - b
			fmt.printfln("a(%v) - b(%v) = %v", a, b, a-b)

		}
		total += sum
	}
	fmt.println("Total is", total)
}
