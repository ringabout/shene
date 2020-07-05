import macros, strformat


type
  ImplError* = object of CatchableError

  Must*[U; T: object | ref object] {.requiresInit.} = object 
    class: U
    obj: T


proc initSubClass*[U, T](m: Must[U, T]) =
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

# macro mcall*(obj: Must, call: untyped, params: varargs[untyped]): untyped =
#   result = newStmtList()
#   var tmp = newNimNode(nnkCall)
#   let dot = newDotExpr(newDotExpr(obj, ident"class"), call)
#   tmp.add(dot)
#   tmp.add(newDotExpr(obj, ident"obj"))
#   for param in params:
#     tmp.add(param)
#   result.add tmp

macro mcall*(obj: Must, call: untyped, params: varargs[untyped]): untyped =
  result = newStmtList()
  var tmp = newNimNode(nnkCall)

  let 
    dot = newDotExpr(newDotExpr(obj, ident"class"), call)
    # if obj.class.call == nil: raise ImplError()
    infixNode = infix(dot, "==", newNilLit())
    raiseNode = newCall(ident"newException",
                        ident"ImplError",
                        newStrLitNode(fmt"{call.toStrLit} can't be empty!"))

    raiseStmt = newNimNode(nnkRaiseStmt).add(raiseNode)
    ifStmt = newIfStmt(
              (infixNode, raiseStmt)
              )
  
  tmp.add(dot)
  tmp.add(newDotExpr(obj, ident"obj"))
  for param in params:
    tmp.add(param)

  result.add ifStmt
  result.add tmp
  

template call*(obj: Must, call: untyped, params: varargs[untyped]): untyped =
  mcall(obj, call, params)
