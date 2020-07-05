# shene
Make an Interface using generics for Nim.

## Installation

```
nimble install shene
```

## Examples

First method makes normal interface based on function pointers easier to use. It doesn't support inheritence.

Second method makes magic interface based on function pointers and generics. It supports inheritence or plain object and makes libraries more extensible.

### ucalls

Don't support object inheritence.

```nim
import strformat, sugar
import shene/ucall


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
```



### mcalls

Support extensible object with inheritence or without inheritence.

```nim
import shene/mcall
import strformat


type
  Animal*[T] = object of RootObj
    id: int
    sleepImpl: proc (a: T) {.nimcall, gcsafe.}
    barkImpl: proc (a: T, b: int, c: int): string {.nimcall, gcsafe.}
    danceImpl: proc (a: T, b: string): string {.nimcall, gcsafe.}

  # support extensible object inheritence
  Cat* = object of Animal[Cat]
    cid: int

  People*[T] = object
    pet: Must[Animal[T], T]


proc sleep*(a: Cat) =
  discard

proc bark*(a: Cat, b: int, c: int): string =
  result = fmt"{a.cid + b + c = }"

proc dance*(a: Cat, b: string): string =
  result = fmt"{a.id = } |-| {b = }"

proc newCat*(id, cid: int): Must[Animal[Cat], Cat] =
  result.id = id
  result.cid = cid
  result.sleepImpl = sleep
  result.barkImpl = bark
  result.danceImpl = dance

let p = People[Cat](pet: newCat(id = 12, 13))
echo p.pet.call(barkImpl, 13, 14)
echo p.pet.id
echo p.pet.cid

# output:
# a.cid + b + c = 40
# 12
# 13


type
  # support extensible object inheritence
  Dog = object
    name: string


proc bark(d: Dog, b: int, c: int): string =
  echo "Dog"
  echo d.name

proc newDog(): Must[Animal[Dog], Dog] =
  result.name = "OK"
  result.id = 12
  result.barkImpl = bark


let d = newDog()
let p1 = People[Dog](pet: d)
discard p1.pet.call(barkImpl, 13, 14)

doAssertRaises(ImplError):
  p1.pet.call(sleepImpl)
echo p1.pet.id
```
