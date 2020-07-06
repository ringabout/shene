# shene

Zero-cost interface for Nim.

## Installation

```
nimble install shene
```

## Ideas

### Decouple `impl` and `data`

`Impl` represents `Impl Class` and `data` stands for `Data Class`. `Impl Class` supplies all interfaces which should be satisfied. `Data Class` supplies all attributes that can be extended by users. They both support inheritance.

```nim
type
  Must*[U: object; T: object | ref object] = object 
    impl*: U
    data*: T
```



#### Impl Class

We define function pointers just like before, but now the first parameter of function declarations should be generics type. We also should only define function pointers without any other attributes.

```nim
type
  Animal*[T] = object of RootObj
    sleepImpl: proc (a: T) {.nimcall, gcsafe.}
    barkImpl: proc (a: var T, b: int, c: int): string {.nimcall, gcsafe.}
    danceImpl: proc (a: T, b: string): string {.nimcall, gcsafe.}
```



#### Data Class

Data Class contains all user-defined attributes. You can add data attributes by means of inheritance. But be careful, now we need `Must[Animal[Cat], Cat]` type as the type of our object which is passed to `People` object. `shene` supplies `must(Animal, Dog)` which is a helper templates to simplify type declaration. It also overloads `dot operator` and makes assignment easier

```nim
# If class is ref object, user must `new Must.data` or `init Must`.
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

Regarding People class, we need additional generics type. `must(Animal, T)` is the helper templates for `Must[Animal[T], T]`. 

```nim
type
  People*[T] = object
    pet: must(Animal, T)
```



#### Usage

Its usage is very simple. We only need to add additional generics type. There is little difference compared to before.

```nim
var d = newDog()
var p1 = People[Dog](pet: d)
discard p1.pet.call(barkImpl, 13, 14)
```
