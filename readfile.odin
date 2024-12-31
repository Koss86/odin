package line_by_line

import "core:os"
import "core:strings"
import "core:fmt"

read_file_by_lines_in_whole :: proc(filepath: "input1.txt") {
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		// process line
		fmt.println(line)
	}
}

