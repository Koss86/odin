package hangman
import "core:os"
import "core:fmt"
import "core:math"
import "core:bytes"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"



main :: proc() {
    //list := []string {"coffee", "castaway", "broken", "laptop", "driven"}
    buff: [16]byte
    w, h: int
    num_bytes: int
    for num_bytes != 3 {
        fmt.print("Width? ")
        num_bytes, _ = os.read(os.stdin, buff[:])
    }

    indx := bytes.index_byte(buff[:], 13)
    tmp_str := string(buff[:])
    w = strconv.atoi(tmp_str[:indx])
    
    for num_bytes != 3 {
        fmt.print("\nHeight? ")
        num_bytes, _ = os.read(os.stdin, buff[:])

        indx = bytes.index_byte(buff[:], 13)
        h = strconv.atoi(tmp_str[:indx])
    }

    for i in 0..<h {
        for j in 0..<w {
            fmt.printf("#")
        }
        fmt.println()
    }
}