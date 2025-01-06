package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

SIZE :: 1000
LEN :: 5

Vec2s :: [2] string
Vec2i :: [2] int
loc_struct :: struct {
	loc1: [5] int,
	loc2: [5] int,
}

main :: proc() {
    file := "aoc/2024/inputs/input1.txt"
    data, ok := os.read_entire_file(file, context.allocator)

	if !ok {
		fmt.println("Error reading input.")
		return
	}
	defer delete(data, context.allocator)

	locations_strs: [SIZE] Vec2s
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
					locations_strs[i].x = str
					count += 1
				} else {
					locations_strs[i].y = str
					count = 0
				}
			}
		}
	}
	//tmp := locations_strs[i].x[i]
	//tmp = my_atoi(tmp)
	locations_nums: [SIZE] loc_struct
	for i in 0..<SIZE {
		for j in 0..<LEN {
			tmp:= locations_strs[i].x[j]
		}
	}


}


my_atoi :: proc(i: u8) -> u8 {
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