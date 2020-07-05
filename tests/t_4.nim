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

  Cat* = object of Animal[Cat]
    cid: int

  Dog* = object of Animal[Dog]
    did: int

  People*[T, U] = object
    pet0: must(Animal, T)
    pet1: must(Animal, U)


proc sleep*(a: Cat) =
  discard

proc bark*(a: Cat, b: int, c: int): string =
  result = fmt"{a.cid + b + c = }"

proc dance*(a: Cat, b: string): string =
  result = fmt"{a.id = } |-| {b = }"

proc sleep*(a: Dog) =
  for i in 0 ..< a.did:
    discard

proc bark*(a: Dog, b: int, c: int): string =
  discard fmt"{a.did + b + c = }"

proc dance*(a: Dog, b: string): string =
  discard fmt"{a.id = } |-| {b = }"

proc newCat*(id, cid: int): must(Animal, Cat) =
  result.id = id
  result.cid = cid
  result.sleepImpl = sleep
  result.barkImpl = bark
  result.danceImpl = dance

proc newDog*(id, did: int): must(Animal, Dog) =
  result.id = id
  result.did = did
  result.sleepImpl = sleep
  result.barkImpl = bark
  result.danceImpl = dance

let p = People[Cat, Dog](pet0: newCat(id = 12, 13), pet1: newDog(1, 2))
doAssert p.pet0.call(barkImpl, 13, 14) == "a.cid + b + c = 40"
p.pet0.call(sleepImpl)
doAssert p.pet0.id == 12
doAssert p.pet0.cid == 13

discard p.pet1.call(barkImpl, 13, 14)
p.pet1.call(sleepImpl)
discard p.pet1.id
discard p.pet1.did
# echo p.pet.barkImpl
# echo p.pet.mget(barkImpl)
