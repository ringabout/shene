discard """
output: '''
a.cid + b + c = 40
12
13
a.cid + b + c = 113
Dog
OK
777
777
'''
"""


import strformat
import ../src/shene/mcall


type
  Animal*[T] = object of RootObj
    id: int
    sleepImpl: proc (a: T) {.nimcall, gcsafe.}
    barkImpl: proc (a: var T, b: int, c: int): string {.nimcall, gcsafe.}
    danceImpl: proc (a: T, b: string): string {.nimcall, gcsafe.}

  Cat* = object of Animal[Cat]
    cid: int

  Others*[T] = object of Animal[T]
    clearImpl: proc (a: var T) {.nimcall, gcsafe.}

  People*[T] = object
    pet: Must[Animal[T], T]
    other: Must[Others[T], T]


proc sleep*(a: Cat) =
  discard

proc bark*(a: var Cat, b: int, c: int): string =
  result = fmt"{a.cid + b + c = }"

proc dance*(a: Cat, b: string): string =
  result = fmt"{a.id = } |-| {b = }"

proc newCat*(id, cid: int): Must[Animal[Cat], Cat] =
  result.id = id
  result.cid = cid
  result.sleepImpl = sleep
  result.barkImpl = bark
  result.danceImpl = dance


var p = People[Cat](pet: newCat(id = 12, 13))
echo p.pet.call(barkImpl, 13, 14)
p.pet.call(sleepImpl)
echo p.pet.id
echo p.pet.cid

var m = newCat(13, 14)
echo m.call(barkImpl, 12, 87)
# discard p.pet.barkImpl
# echo p.pet.mget(barkImpl)


type
  Dog = object
    id: int
    name: string

  Monkey = object of Others[Monkey]
    mid: int


proc bark(d: var Dog, b: int, c: int): string =
  echo "Dog"
  echo d.name
  d.id = 777
  echo d.id

proc clear(m: var Monkey) =
  m.id = 0
  m.mid = 0

proc newDog(): Must[Animal[Dog], Dog] =
  result.name = "OK"
  result.id = 12
  result.barkImpl = bark


proc newMonkey(): Must[Others[Monkey], Monkey] =
  result.obj.id = 12
  result.obj.mid = 777
  result.clearImpl = clear

var monkey = newMonkey()
monkey.obj.id = 999
monkey.call(clearImpl)


var d = newDog()
var p1 = People[Dog](pet: d)
discard p1.pet.call(barkImpl, 13, 14)


doAssertRaises(ImplError):
  p1.pet.call(sleepImpl)
echo p1.pet.id
