import macros


type
  ImplError* = object of CatchableError

  Must*[U: object; T: object | ref object] = object 
    impl: U
    data*: T


template must*(a, b: typedesc): untyped =
  Must[a[b], b]

template init*(must: Must) =
  when must.data is ref object:
    if must.data == nil:
      new must.data

template get*(must: Must, attrs: untyped): untyped =
  when compiles(typeof(must.impl.attrs) is proc):
    must.impl.attrs
  else:
    must.data.attrs

template `.`*(must: Must, attrs: untyped): untyped =
  must.get(attrs)

template put*(must: var Must, call: untyped, fun: untyped) =
  when compiles(typeof(must.impl.call) is proc):
    must.impl.call = fun
  else:
    must.data.call = fun

template `.=`*(must: var Must, call: untyped, fun: untyped) {.dirty.} =
  must.put(call, fun)

macro call*(must: Must, call: untyped, params: varargs[untyped]): untyped =
  result = newStmtList()
  var tmp = newNimNode(nnkCall)

  let
    # must.impl.call
    dot = newDotExpr(newDotExpr(must, ident"impl"), call)
    # if must.impl.call == nil: raise newException(ImplError, "Impl can't empty!")
    infixNode = infix(dot, "==", newNilLit())
    raiseNode = newCall(ident"newException",
                        ident"ImplError",
                        newStrLitNode($call.toStrLit & " can't be empty!"))

    raiseStmt = newNimNode(nnkRaiseStmt).add(raiseNode)
    ifStmt = newIfStmt(
              (infixNode, raiseStmt)
              )

  # call must.impl.call(must.data, params)
  tmp.add(dot)
  tmp.add(newDotExpr(must, ident"data"))
  for param in params:
    tmp.add(param)

  result.add ifStmt
  result.add tmp
