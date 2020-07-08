from strutils import join


template autoImport*(module: static[string]): untyped =
   import module

template importFrom*(module: static[string], needs: varargs[static[string]]): untyped =
  let result = join(needs)
  from module import result

template importExcept*(module: static[string], excepts: varargs[static[string]]): untyped =
  let result = join(excepts)
  import module except excepts
