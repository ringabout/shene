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
    sleepImpl: proc (a: T) {.nimcall, gcsafe.}
    barkImpl: proc (a: var T, b: int, c: int): string {.nimcall, gcsafe.}
    danceImpl: proc (a: T, b: string): string {.nimcall, gcsafe.}

  Cat* = object
    cid: int

  Others*[T] = object of Animal[T]
    clearImpl: proc (a: var T) {.nimcall, gcsafe.}

  People*[T] = object
    pet: must(Animal, T)
    other: must(Others, T)


proc sleep*(a: Cat) =
  discard

proc bark*(a: var Cat, b: int, c: int): string =
  result = fmt"{a.cid + b + c = }"

proc dance*(a: Cat, b: string): string =
  result = fmt"{b = }"

proc newCat*(cid: int): must(Animal, Cat) =
  result.cid = cid
  result.sleepImpl = sleep
  result.barkImpl = bark
  result.danceImpl = dance


var p = People[Cat](pet: newCat(13))
doAssert p.pet.call(barkImpl, 13, 14) == "a.cid + b + c = 40"
p.pet.call(sleepImpl)
doAssert p.pet.cid == 13

var m = newCat(14)
doAssert m.call(barkImpl, 12, 87) == "a.cid + b + c = 113"
# discard p.pet.barkImpl
# echo p.pet.mget(barkImpl)


type
  Dog = ref object
    id: string
    did: int
    name: string

  Monkey = object
    mid: int


proc bark(d: var Dog, b: int, c: int): string =
  doAssert d.name == "OK"
  d.did = 777
  doAssert d.did == 777
  d.id = "First"
  doAssert d.id == "First"

proc clear(m: var Monkey) =
  m.mid = 0

proc newDog(): must(Animal, Dog) =
  init result
  result.name = "OK"
  result.did = 12
  result.barkImpl = bark

proc newMonkey(): must(Others, Monkey) =
  result.mid = 777
  result.clearImpl = clear
  doAssert result.mid == 777

var monkey = newMonkey()
monkey.call(clearImpl)
doAssert monkey.mid == 0


var d = newDog()
echo sizeof(Animal)
echo sizeof(d)
var p1 = People[Dog](pet: move(d))
discard p1.pet.call(barkImpl, 13, 14)

let x = p.pet.barkImpl
var c = Cat(cid: 2)
doAssert x(c, 12, 3) == "a.cid + b + c = 17"


doAssertRaises(ImplError):
  p1.pet.call(sleepImpl)
doAssert p1.pet.did == 777
