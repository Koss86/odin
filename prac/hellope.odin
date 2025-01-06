package main

import "core:fmt"
import "core:os"

main :: proc() {

    fmt.println("Hellope!")
    fmt.println("newline?\nYep!")
    
    buf: [256]byte
	fmt.println("Please enter some text:")
	n, err := os.read(os.stdin, buf[:])
	if err != nil {
		fmt.eprintln("Error reading: ", err)
		return
	}
	str := string(buf[:n])
	fmt.println("Outputted text:", str)

}