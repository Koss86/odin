package main

import "core:fmt"
import "core:os"
//import "core:strings"
import "core:strconv"

main :: proc() {

    //buf: [256]byte
	//fmt.println("Please enter some text:")
	//n, err := os.read(os.stdin, buf[:])
	//if err != nil {
        //	fmt.eprintln("Error reading: ", err)
        //	return
        //}
    //str := string(buf[:n])
    //fmt.println("Outputted text:", str)

    tmp: [256] byte 
    fmt.println("Height?")

    num, err := os.read(os.stdin, tmp[:]) // is this returning length?
    if err != nil {
        fmt.eprintln("Error reading: ", err)
        return
    }
    
    hstr:string= string(tmp[:num])
    h:= strconv.atoi(hstr)

    fmt.println("Width?")

    num, err = os.read(os.stdin, tmp[:])
    if err != nil {
        fmt.eprintln("Error reading: ", err)
    }

    wstr:= string(tmp[:num]) 
    w:= strconv.atoi(wstr)
    

    for i:= 0; i < h; i +=1 {
        for j:= 0; j < w; j +=1 {
            fmt.printf("#")
        }
        fmt.println("")
    }
    
}