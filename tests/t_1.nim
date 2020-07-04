discard """
output: '''
a.barkImpl(a, 13, 5) = a.id + b + c = 30
a.danceImpl(a, "Nim") = a.id = 12 |-| b = Nim
a.id + b + c = 53
a.id + b + c = 53
a.id = 12 |-| b = Nim
a.id = 12 |-| b = Nim
a.id + b + c = 53
a.id + b + c = 53
a.id + b + c = 55
a.id + b + c = 55
a.id + b + c = 178
a.id + b + c = 178
'''
"""

import strformat, sugar
import ../src/shene


type
  Animal* = object of RootObj
    id: int
    sleepImpl: proc (a: Animal) {.nimcall, gcsafe.}
    barkImpl: proc (a: Animal, b: int, c: int): string {.nimcall, gcsafe.}
    danceImpl: proc (a: Animal, b: string): string {.nimcall, gcsafe.}

  LongAndUgly* = object
    pet: Animal

  People* = object
    longAndUgly: LongAndUgly

  Cat* = object of Animal
    cid: int


proc sleep*(a: Animal) =
  discard

proc bark*(a: Animal, b: int, c: int): string =
  result = fmt"{a.id + b + c = }"

proc dance*(a: Animal, b: string): string =
  result = fmt"{a.id = } |-| {b = }"

proc newAnimal(id: int): Animal =
  result.id = id
  result.sleepImpl = sleep
  result.barkImpl = bark
  result.danceImpl = dance

let a = newAnimal(12)
dump a.barkImpl(a, 13, 5)
dump a.danceImpl(a, "Nim")


let people = People(longAndUgly: LongAndUgly(pet: a))

echo people.longAndUgly.pet.barkImpl(people.longAndUgly.pet, 27, c = 14)
echo people.longAndUgly.pet.ucall(barkImpl, 27, c = 14)

people.longAndUgly.pet.sleepImpl(people.longAndUgly.pet)
people.longAndUgly.pet.ucall(sleepImpl)

echo people.longAndUgly.pet.danceImpl(people.longAndUgly.pet, "Nim")
echo people.longAndUgly.pet.ucall(danceImpl, "Nim")

echo a.barkImpl(a, 27, c = 14)
echo a.ucall(barkImpl, 27, c = 14)

echo Animal(id: 12, barkImpl: bark, danceImpl: dance).
            barkImpl(Animal(id: 12, barkImpl: bark, danceImpl: dance), 27, c = 16)
echo Animal(id: 12, barkImpl: bark, danceImpl: dance).ucall(barkImpl, 27, c = 16)

template nice =
  echo newAnimal(13).barkImpl(newAnimal(13), 66, 99)
  echo newAnimal(13).ucall(barkImpl, 66, 99)

nice()
