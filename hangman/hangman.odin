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

    input := string(buff)
    seed := rand.uint32()
    fmt.println(input)

    rl.SetRandomSeed(seed)
    key := random_num(0, 19)
    os_platform := info.os_version.platform

    expected_leng: int
    if os_platform == .Linux {
        expected_leng = LINUX_NUM_RETURNS
    } else if os_platform == .Windows {
        expected_leng = WINDOWS_NUM_RETURNS
    }
    
    indx: int
    fmt.print("Guess a letter: ")
    num_of_stdin, _ := os.read(os.stdin, buff[:])

    for num_of_stdin != expected_leng || buff[0] == SPACE {
        fmt.printf("\nPlease guess one letter only and no spaces.\n\nGuess a letter: ")
        num_of_stdin, _ = os.read(os.stdin, buff[:])
    }

    //fmt.println(num_of_stdin)
    //fmt.println(buff[0])

    tmp_str := string(buff[:])
    
    if os_platform == .Linux {
        indx = bytes.index_byte(buff[:], 10)
    } else if os_platform == .Windows {
        indx = bytes.index_byte(buff[:], 13)
    }
    
}