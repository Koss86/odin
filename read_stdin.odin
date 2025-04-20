package read_stdin

import "core:fmt"
import "core:os"
import "core:sys/info"

SPACE :: 32
LINUX_NUM_RETURNS :: 2
WINDOWS_NUM_RETURNS :: 3

main :: proc() {
  buff: []byte
  expected_leng: int
  os_platform := info.os_version.platform
  #partial switch os_platform {
  case .Linux:
    expected_leng = LINUX_NUM_RETURNS
  case .Windows:
    expected_leng = WINDOWS_NUM_RETURNS
  case:
    fmt.printfln("Error. Unknown OS.")
    return
  }

  fmt.print("Guess a letter: ")
  num_of_stdin, _ := os.read(os.stdin, buff[:])
  for num_of_stdin != expected_leng ||
      buff[0] == SPACE ||
      buff[0] >= '0' && buff[0] <= '9' {
    fmt.printf(
      "\nPlease guess one letter only, no spaces or numbers.\n\nGuess a letter: ",
    )
    num_of_stdin, _ = os.read(os.stdin, buff[:])
  }

  tmp_str := string(buff[:])
  indx: int
  #partial switch os_platform {
  case .Linux:
    indx = bytes.index_byte(buff[:], 10)
  case .Windows:
    indx = bytes.index_byte(buff[:], 13)
  }
  guess := tmp_str[:indx]
  fmt.println(guess)
}
