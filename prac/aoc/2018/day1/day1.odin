package day1
import "core:fmt"
import "core:os"
import strs "core:strings"
import strc "core:strconv"

main :: proc() {
    buff, ok := os.read_entire_file_from_filename("../inputs/input1.txt", context.allocator)
    if !ok {
        fmt.eprintln("Error. Unable to read file.")
        return
    }
    
    found: bool
    frequency: int
    it := string(buff)
    frequencies := make([dynamic] int)

    for line in strs.split_lines_iterator(&it) {
            num := strc.atoi(line)
            frequency += num
            append(&frequencies, frequency)
        }
    for !found {
        for i in 0..<len(frequencies) {
            found = if_found(frequencies[:], frequencies[i], i)
            if found {
                fmt.printfln("Match found at frequency %v!", frequencies[i])
                found = true
                return
            }
        }
        leng := len(frequencies)
        frequency = frequencies[leng-1]
        for i in 0..<leng {
            frequency += frequencies[i]
            append(&frequencies, frequency)
        }
        fmt.println(cap(frequencies))
    }

    //fmt.println(frequency)
}
if_found :: proc (list: [] int, find: int, skip_indx: int) -> bool {
    leng := len(list)
    found: bool
    //fmt.println(skip_indx)
    for i in 0..<leng {
        if i == skip_indx {
            continue
        } else if find == list[i] {
            found = true
        }
        
    }
    return found
}