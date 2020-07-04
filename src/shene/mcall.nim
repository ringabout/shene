import macros


type
  Must*[U, T] = object 
    class: U
    obj: T


macro get*(must: Must, attrs: untyped): untyped =
  result = quote do:
    when compiles(`must`.class.`attrs`):
      `must`.class.`attrs`
    else:
      `must`.obj.`attrs`

template `.`*(must: Must, attrs: untyped): untyped =
  must.get(attrs)

macro put*(must: var Must, call: untyped, fun: untyped) =
  result = quote do:
    when compiles(must.class.call):
      must.class.call = fun
    else:
      must.obj.call = fun

template `.=`*(must: var Must, call: untyped, fun: untyped) =
  #TODO bug can't reuse macros put
  when compiles(must.class.call):
    must.class.call = fun
  else:
    must.obj.call = fun

macro call*(obj: Must, call: untyped, params: varargs[untyped]): untyped =
  result = newStmtList()
  var tmp = newNimNode(nnkCall)
  let dot = newDotExpr(newDotExpr(obj, ident"class"), call)
  tmp.add(dot)
  tmp.add(newDotExpr(obj, ident"obj"))
  for param in params:
    tmp.add(param)
  result.add tmp
