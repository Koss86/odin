package main

import "core:os"
import "core:strings"
import "core:fmt"

SIZE :: 1000

main :: proc() {
    file := "aoc/2024/inputs/input1.txt"
    read_file(file)
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