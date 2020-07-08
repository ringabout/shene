discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "--gc:refc; --gc:arc"
  targets:  "c"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""

import strformat
import ../src/shene/mcall


# Constructor injection
type
  Animal*[T] = object
    sleepImpl: proc (a: T) {.nimcall, gcsafe.}
    barkImpl: proc (a: T, b: int, c: int): string {.nimcall, gcsafe.}
    danceImpl: proc (a: T, b: string): string {.nimcall, gcsafe.}

  Phone*[T] = object
    playImpl: proc (a: T) {.nimcall, gcsafe.}

  Cat* = object
    cid: int

  Iphone* = object
    pid: int

  People*[T, U] = object
    id: int
    pet: must(Animal, T)
    phone: must(Phone, U)


proc sleep*(a: Cat) =
  discard

proc bark*(a: Cat, b: int, c: int): string =
  result = fmt"{a.cid + b + c}"

proc dance*(a: Cat, b: string): string =
  result = fmt"{b}"

proc play*(a: Phone) =
  echo "Hello, the phone is playing the music."

proc play*(a: Iphone) =
  echo "Hello, the iphone is playing the music."

proc initCat*(cid: int): must(Animal, Cat) =
  result.cid = cid
  result.sleepImpl = sleep
  result.barkImpl = bark
  result.danceImpl = dance

proc initPhone*(pid: int): must(Phone, Iphone) =
  result.pid = pid
  result.playImpl = play
 
proc initPeople*[T, U](pet: Must[Animal[T], T], phone: Must[Phone[U], U]): People[T, U] =
  result.id = 2333
  result.pet = pet
  result.phone = phone

proc prepare(p: People[Cat, Iphone]) =
  doAssert p.pet.call(barkImpl, 13, 14) == "40"
  p.pet.call(sleepImpl)
  doAssert p.pet.call(danceImpl, "Hello") == "Hello"
  doAssert p.pet.cid == 13
  p.phone.call(playImpl)
  doAssert p.phone.pid == 2333

let pet = initCat(13)
let phone = initPhone(2333)
let p = initPeople[Cat, Iphone](pet, phone)
prepare(p)
