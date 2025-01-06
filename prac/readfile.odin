package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

SIZE :: 1000
LEN :: 5

Vec2s :: [2] string
Vec2i :: [2] int
loc_str_struc :: struct {
	loc1: string,
	loc2: string
}
loc_struct :: struct {
	loc1: [5] u8,
	loc2: [5] u8
}

main :: proc() {
    file := "aoc/2024/inputs/input1.txt"
    data, ok := os.read_entire_file(file, context.allocator)

	if !ok {
		fmt.println("Error reading input.")
		return
	}
	defer delete(data, context.allocator)

	locations_str: [SIZE] loc_str_struc
	it := string(data)

	for i in 0..<SIZE {
		for line in strings.split_lines_iterator(&it) {
			if !ok {
			fmt.println("Error in split_lines_iterator")
			}
			ns := line
			splits := [?]string {"   ", "-"}
			count: int
			for str in strings.split_multi_iterate(&ns, splits[:]) {
				if !ok {
					fmt.println("Error in split_multi_iterate")
				}
				if count == 0 {
					locations_str[i].loc1 = str
					count += 1
				} else {
					locations_str[i].loc2 = str
					count = 0
				}
			}
		}
	}
	//tmp := locations_str[i].x[i]
	//tmp = c_atoi(tmp)
	locations_num: [SIZE] loc_struct
	nums := locations_num
	strs := locations_str
	for i in 0..<SIZE {
		for j: int; j < SIZE; j += 1 {
			tmp:= strs[i].loc1[j]
			nums[i].loc1[j] = c_atoi(tmp)
			tmp = strs[i].loc2[j]
			nums[i].loc2[j] = c_atoi(tmp)
		}
	}
	for i in 0..<SIZE {
		for j in 0..<LEN {
			fmt.printf("%v", nums[i].loc1[j])
		}
		fmt.printf(" ")
		for j in 0..<LEN {
			fmt.printf("%v", nums[i].loc2[j])
		}
		fmt.println("")
	} 

}


c_atoi :: proc(i: u8) -> u8 {
	tmp := i
	tmp = i-48
	return tmp
}







read_file :: proc(filepath: string) {
	data, ok := os.read_entire_file(filepath, context.temp_allocator)
	if !ok {
		fmt.println("Error reading input.")
		return
	}
	defer delete(data, context.temp_allocator)

	it := string(data)

	for i in 0..<SIZE {
		for line in strings.split_lines_iterator(&it) {
			if ok {
				fmt.printf("%v", it)
			}	
		}
	}
}