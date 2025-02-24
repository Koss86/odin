package hangman
import "core:os"
import "core:fmt"
import "core:math/rand"
import "core:bytes"
import "core:strconv"
import "core:strings"
import "core:sys/info"
import rl "vendor:raylib"

LINUX_NUM_RETURNS :: 2
WINDOWS_NUM_RETURNS :: 3
SPACE :: 32
BANK_SIZE :: 20

random_num :: proc(min: int, max: int) -> int {
    min := i32(min)
    max := i32(max)
    seed := rand.uint32()
    rl.SetRandomSeed(seed)
    return int(rl.GetRandomValue(min, max))
}

main :: proc() {
    buff, ok := os.read_entire_file("word_bank.txt", context.temp_allocator)
    word_bank := make([]string, BANK_SIZE, context.allocator)

    indx: int
    input := string(buff)
    for str in strings.split_iterator(&input, ",") {
        word_bank[indx] = strings.clone(str, context.allocator)
        indx += 1
    }
    
    key := random_num(0, BANK_SIZE-1)
    answer := word_bank[key]
    os_platform := info.os_version.platform

    expected_leng: int
    #partial switch os_platform {
        case .Linux:
        expected_leng = LINUX_NUM_RETURNS
        case .Windows: 
        expected_leng = WINDOWS_NUM_RETURNS
        case:
        fmt.printfln("Error. Unknown OS.")
        return
    }
    
    indx = 0
    fmt.print("Guess a letter: ")
    num_of_stdin, _ := os.read(os.stdin, buff[:])

    for num_of_stdin != expected_leng || buff[0] == SPACE || 
        buff[0] >= '0' && buff[0] <= '9' {
            fmt.printf("\nPlease guess one letter only, no spaces or numbers.\n\nGuess a letter: ")
            num_of_stdin, _ = os.read(os.stdin, buff[:])
    }
    //fmt.println(num_of_stdin)
    //fmt.println(buff[0])

    tmp_str := string(buff[:])
    
    #partial switch os_platform {
        case .Linux:
        indx = bytes.index_byte(buff[:], 10)
        case .Windows: 
        indx = bytes.index_byte(buff[:], 13)
    }
    guess := tmp_str[:indx]
    fmt.println(guess)
}