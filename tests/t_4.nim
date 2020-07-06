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


type
  Animal*[T] = object of RootObj
    id: int
    sleepImpl: proc (a: T) {.nimcall, gcsafe.}
    barkImpl: proc (a: T, b: int, c: int): string {.nimcall, gcsafe.}
    danceImpl: proc (a: T, b: string): string {.nimcall, gcsafe.}

  Cat* = object
    cid: int

  Dog* = object
    did: int

  People*[T, U] = object
    pet0: must(Animal, T)
    pet1: must(Animal, U)


proc sleep*(a: Cat) =
  discard

proc bark*(a: Cat, b: int, c: int): string =
  result = fmt"{a.cid + b + c = }"

proc dance*(a: Cat, b: string): string =
  result = fmt"{b = }"

proc sleep*(a: Dog) =
  for i in 0 ..< a.did:
    discard

proc bark*(a: Dog, b: int, c: int): string =
  discard fmt"{a.did + b + c = }"

proc dance*(a: Dog, b: string): string =
  discard fmt"{b = }"

proc newCat*(cid: int): must(Animal, Cat) =
  result.cid = cid
  result.sleepImpl = sleep
  result.barkImpl = bark
  result.danceImpl = dance

proc newDog*(did: int): must(Animal, Dog) =
  result.did = did
  result.sleepImpl = sleep
  result.barkImpl = bark
  result.danceImpl = dance

let p = People[Cat, Dog](pet0: newCat(13), pet1: newDog(2))
doAssert p.pet0.call(barkImpl, 13, 14) == "a.cid + b + c = 40"
p.pet0.call(sleepImpl)
doAssert p.pet0.cid == 13

discard p.pet1.call(barkImpl, 13, 14)
p.pet1.call(sleepImpl)
discard p.pet1.did
# echo p.pet.barkImpl
# echo p.pet.mget(barkImpl)
