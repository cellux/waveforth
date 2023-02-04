import std/strutils

import cligen

import vm
import nodes
import sample_buffer

iterator wordsInString(s: string): string =
  for word in s.splitWhitespace():
    yield word

iterator wordsInFile(filename: string): string =
  let contents = readFile(filename)
  for word in wordsInString(contents):
    yield word

proc main(
  files: seq[string],
  output: string = "out.wav",
  expr: string = "",
  sampleRate: float = 48000) =
  if len(files) == 0 and expr == "":
    raise newException(HelpError, "Provide a file to interpret or a script via -e.\n${HELP}")
  var vm = VM(sampleRate: sampleRate)
  registerNodes(vm)
  var input = newSeq[string]()
  for f in files:
    for word in wordsInFile(f):
      input.add(word)
  if len(expr) > 0:
    for word in wordsInString(expr):
      input.add(word)
  vm.processWords(input)
  let sampleBuffer = vm.renderSamples()
  sampleBuffer.save(output)

cligen.dispatch main
