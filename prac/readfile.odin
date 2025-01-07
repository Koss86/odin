package main

import "core:os"
import "core:fmt"
import "core:strings"

SIZE :: 1000
LEN :: 5

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
	locations_str: [SIZE] loc_str_struc
	indx: int

    data, ok := os.read_entire_file(file, context.allocator)
	if !ok {
		fmt.println("Error reading input.")
		return
	}
	it := string(data)
	defer delete(data, context.allocator)


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
				locations_str[indx].loc1 = strings.clone(str, context.allocator)
				count += 1
			} else {
				//fmt.printfln("indx is %v", indx)
				locations_str[indx].loc2 = strings.clone(str, context.allocator)
				count = 0
				indx += 1
			}
		}
	}
	locations_num: [SIZE] loc_struct

	for i in 0..<SIZE {
		//fmt.printfln("i is %v", i)
		for j: int; j < LEN; j += 1 {
			//fmt.printfln("j is %v", j)

			tmp:= locations_str[i].loc1[j]
			locations_num[i].loc1[j] = c_atoi(tmp)

			tmp = locations_str[i].loc2[j]
			locations_num[i].loc2[j] = c_atoi(tmp)

			//fmt.printfln("%r", locations_str[i].loc1[j])
		}
	}
	for i in 0..<SIZE {
		for j in 0..<LEN {
			fmt.printf("%v", locations_num[i].loc1[j])
		}
		fmt.printf(" ")

		for j in 0..<LEN {
			fmt.printf("%v", locations_num[i].loc2[j])
		}
		fmt.println("")
	} 

}


c_atoi :: proc(i: u8) -> u8 {
	tmp := i
	tmp = tmp-48
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