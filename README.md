# shene

Zero-cost interface for Nim.

## Installation

```
nimble install shene
```

## Ideas

### Decouple `impl` and `data`

`Impl` represents `Impl Class` and `data` stands for `Data Class`.  `Impl Class` supplies all interfaces which should be satisfied. It shouldn’t be inherited. `Data Class` supplies all attributes that can be extended by users. It supports inheritance.

```nim
type
  Must*[U; T: object | ref object] = object 
    impl: U
    data: T
```



#### Impl Class

```nim
type
  Animal*[T] = object of RootObj
    sleepImpl: proc (a: T) {.nimcall, gcsafe.}
    barkImpl: proc (a: var T, b: int, c: int): string {.nimcall, gcsafe.}
    danceImpl: proc (a: T, b: string): string {.nimcall, gcsafe.}
```



#### Data Class

If class is ref object, user must `new Must.data` or `init Must`. 

```nim
type
  Dog = object
    id: string
    did: int
    name: string


proc bark(d: var Dog, b: int, c: int): string =
  doAssert d.name == "OK"
  d.did = 777
  doAssert d.did == 777
  d.id = "First"
  doAssert d.id == "First"

# must(Impl class, Data class)
proc newDog(): must(Animal, Dog) =
  result.name = "OK"
  result.did = 12
  result.barkImpl = bark
```



#### Oriented-User Class

```nim
type
  People*[T] = object
    pet: must(Animal, T)
```



#### Usage

```nim
var d = newDog()
var p1 = People[Dog](pet: d)
discard p1.pet.call(barkImpl, 13, 14)
```
