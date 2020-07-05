import macros


macro ucall*(obj: typed, call: untyped, params: varargs[untyped]): untyped =
  result = newStmtList()
  var tmp = newNimNode(nnkCall)
  tmp.add(newDotExpr(obj, call))
  tmp.add(obj)
  for param in params:
    tmp.add(param)
  result.add tmp
  echo result.repr
