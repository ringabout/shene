import macros


type
  Must*[U; T: object] {.requiresInit.} = object 
    class: U
    obj: T


proc `=sink`*[U, T](dest: var Must[U, T]; source: Must[U, T]) =
  doAssert T is U
  dest.class = source.class
  dest.obj = source.obj

proc `=`*[U, T](dest: var Must[U, T]; source: Must[U, T]) =
  doAssert T is U
  dest.class = source.class
  dest.obj = source.obj

proc `=destroy`[U, T](x: var Must[U, T]) =
  doAssert T is U
  `=destroy`(x.class)
  `=destroy`(x.obj)


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
