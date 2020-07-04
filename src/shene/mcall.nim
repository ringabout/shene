import macros


type
  Must*[U; T: object] = object 
    class: U
    obj: T


proc init*[U, T](m: Must[U, T]) =
  doAssert T is U

template get*(must: Must, attrs: untyped): untyped =
  when compiles(must.class.attrs):
    must.class.attrs
  else:
    must.obj.attrs

template `.`*(must: Must, attrs: untyped): untyped =
  must.get(attrs)

template put*(must: var Must, call: untyped, fun: untyped) =
  when compiles(must.class.call):
    must.class.call = fun
  else:
    must.obj.call = fun

template `.=`*(must: var Must, call: untyped, fun: untyped) {.dirty.} =
  must.put(call, fun)

macro call*(obj: Must, call: untyped, params: varargs[untyped]): untyped =
  result = newStmtList()
  var tmp = newNimNode(nnkCall)
  let dot = newDotExpr(newDotExpr(obj, ident"class"), call)
  tmp.add(dot)
  tmp.add(newDotExpr(obj, ident"obj"))
  for param in params:
    tmp.add(param)
  result.add tmp
