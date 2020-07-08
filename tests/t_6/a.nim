type
  Dog* = object
    id: int

proc bark*(d: Dog) = 
  echo "From a"
