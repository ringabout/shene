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

  Gamer*[T] = object of RootObj
    id: int
    sleepImpl: proc (a: T) {.nimcall, gcsafe.}

  Cat* = object of Animal[Cat]
    cid: int

  Player* = object of Gamer[Player]
    pid: int

  People*[T, U] = object
    id: int
    pet: Must[Animal[T], T]
    gamer: Must[Gamer[U], U]


proc sleep*(a: Cat) =
  discard

proc bark*(a: Cat, b: int, c: int): string =
  result = fmt"{a.cid + b + c = }"

proc dance*(a: Cat, b: string): string =
  result = fmt"{a.id = } |-| {b = }"

proc sleep*(a: Gamer) =
  echo "Hello, I am asleep."

proc sleep*(a: Player) =
  discard

proc newCat*(id, cid: int): must(Animal, Cat) =
  result.id = id
  result.cid = cid
  result.sleepImpl = sleep
  result.barkImpl = bark
  result.danceImpl = dance

proc newPlayer*(id, pid: int): must(Gamer, Player) =
  result.id = id
  result.pid = pid
  result.sleepImpl = sleep
 

let p = People[Cat, Player](id: 2333, pet: newCat(id = 12, 13),
                            gamer: newPlayer(12, 34))
doAssert p.pet.call(barkImpl, 13, 14) == "a.cid + b + c = 40"
p.pet.call(sleepImpl)
doAssert p.pet.id == 12
doAssert p.pet.cid == 13
p.gamer.call(sleepImpl)
doAssert p.gamer.pid == 34
doAssert p.id == 2333
# echo p.pet.barkImpl
# echo p.pet.mget(barkImpl)
