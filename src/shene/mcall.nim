import macros


type
  Must*[U, T] = object 
    class: U
    obj: T


macro mget*(must: Must, attrs: untyped): untyped =
  result = quote do:
    when compiles(`must`.class.`attrs`):
      `must`.class.`attrs`
    else:
      `must`.obj.`attrs`

template `.=`*(must: var Must, call: untyped, fun: untyped) =
  when compiles(must.class.call):
    must.class.call = fun
  else:
    must.obj.call = fun

macro mcall*(obj: typed, call: untyped, params: varargs[untyped]): untyped =
  result = newStmtList()
  var tmp = newNimNode(nnkCall)
  let dot = newDotExpr(newDotExpr(obj, ident"class"), call)
  tmp.add(dot)
  tmp.add(newDotExpr(obj, ident"obj"))
  for param in params:
    tmp.add(param)
  result.add tmp
