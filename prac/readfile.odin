package main

import "core:os"
import str "core:strings"
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
		for line in str.split_lines_iterator(&it) {
			if ok {
				fmt.printf("%v", it)
			}	
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
		for line in str.split_lines_iterator(&it) {
			if ok {
				fmt.printf("%v", it)
			}	
		}
	}
}