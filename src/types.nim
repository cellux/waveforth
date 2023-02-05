type
  SyntaxError* = object of CatchableError
  NotImplementedError* = object of CatchableError
  RuntimeError* = object of CatchableError

  Sample* = float
  Frame* = array[2, Sample]
