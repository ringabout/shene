discard """
output: '''
a.cid + b + c = 40
12
13
34
2333
'''
"""


import strformat
import ../src/shene


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

proc newCat*(id, cid: int): Must[Animal[Cat], Cat] =
  init(result)
  result.id = id
  result.cid = cid
  result.sleepImpl = sleep
  result.barkImpl = bark
  result.danceImpl = dance

proc newPlayer*(id, pid: int): Must[Gamer[Player], Player] =
  init(result)
  result.id = id
  result.pid = pid
  result.sleepImpl = sleep
 

let p = People[Cat, Player](id: 2333, pet: newCat(id = 12, 13),
                            gamer: newPlayer(12, 34))
echo p.pet.call(barkImpl, 13, 14)
p.pet.call(sleepImpl)
echo p.pet.id
echo p.pet.cid
p.gamer.call(sleepImpl)
echo p.gamer.pid
echo p.id
# echo p.pet.barkImpl
# echo p.pet.mget(barkImpl)
