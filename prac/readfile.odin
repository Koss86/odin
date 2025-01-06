package main

import "core:os"
import "core:strings"
import "core:fmt"

SIZE :: 1000

Vec2s :: [2] string

main :: proc() {
    file := "aoc/2024/inputs/input1.txt"
    data, ok := os.read_entire_file(file, context.temp_allocator)

	if !ok {
		fmt.println("Error reading input.")
		return
	}
	defer delete(data, context.temp_allocator)

	it := string(data)
	locations: [SIZE] Vec2s

	for i in 0..<SIZE {
		for line in strings.split_lines_iterator(&it) {
			if !ok {
			fmt.println("Error in split_lines_iterator")
			}
			ns := line
			splits := [?]string {"   ", "-"}
			count: int
			for str in strings.split_multi_iterate(&ns, splits[:]) {
				if count == 0 {
					locations[i].x = str
					count += 1
				} else {
					locations[i].y = str
					count = 0
				}
			}
			fmt.printf("%v %v\n", locations[i].x, locations[i].y)
		}
	}
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