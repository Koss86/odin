package main

import "core:fmt"
import "core:os"

main :: proc() {

    //buf: [256]byte
    tmp: [256] byte 

	//fmt.println("Please enter some text:")
    fmt.println("Hello, what is your name? ")

	//n, err := os.read(os.stdin, buf[:])
    num, err := os.read(os.stdin, tmp[:]) // is this returning length?

	//if err != nil {
	//	fmt.eprintln("Error reading: ", err)
	//	return
	//}
    if err != nil {
        fmt.eprintln("Error reading: ", err)
        return
    }

	//str := string(buf[:n])
    name := string(tmp[:num])

	//fmt.println("Outputted text:", str)
    fmt.println("Hello,", name)
}