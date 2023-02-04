import std/tables
import std/strutils
import std/options

import types

type
  VMObj* = ref object of RootObj
  VMProc* = proc(vm: var VM)
  VMProcObj* = ref object of VMObj
    vmProc: VMProc
  VM* = ref object
    input: seq[string]
    inputIndex: int
    words: Table[string, VMObj]
    stack: seq[VMObj]
    sampleRate*: float
    tick: int

proc push*(self: var VM, value: VMObj) =
  self.stack.add(value)

proc pop*(self: var VM): VMObj =
  result = self.stack.pop()

proc top*(self: var VM): VMObj =
  let length = len(self.stack)
  result = self.stack[length-1]

import nodes/audio_node

proc next*(vm: var VM, node: AudioNode): Frame =
  if node.tick == vm.tick:
    node.process(vm)
    inc(node.tick)
  result = node.frame

func getNode*[T](self: var VM, name: string, default: T): AudioNode =
  try:
    let value = self.words[name]
    return makeNode(value)
  except KeyError:
    return makeNode(default)

import nodes/float_node

proc processWord*(self: var VM, word: string) =
  if word[0] == ':':
    self.words[word] = self.pop()
  else:
    try:
      let obj = self.words[word]
      if obj of VMProcObj:
        VMProcObj(obj).vmProc(self)
      else:
        self.push(obj)
    except KeyError:
      try:
        let x = word.parseFloat
        self.push(makeNode(x))
      except ValueError:
        raise newException(ParseError, word)

proc nextWord*(self: var VM): Option[string] =
  if self.inputIndex < len(self.input):
    result = some(self.input[self.inputIndex])
    inc(self.inputIndex)

proc processWords*(self: var VM, input: seq[string]) =
  self.input = input
  self.inputIndex = 0
  while true:
    let word = self.nextWord()
    if word.isSome:
      self.processWord(word.get())
    else:
      break

import sample_buffer

proc renderSamples*(self: var VM): SampleBuffer =
  let node = AudioNode(self.top)
  let nframes = node.nframes
  assert nframes > 0
  let nchannels = node.nchannels
  let nsamples = nframes * nchannels
  var samples = newSeq[Sample](nsamples)
  var sampleIndex = 0
  for i in 0..<nframes:
    let frame = self.next(node)
    for ch in 0..<nchannels:
      samples[sampleIndex] = frame[ch]
      inc(sampleIndex)
    inc(self.tick)
  result = SampleBuffer(nchannels: nchannels,
                        nframes: nframes,
                        sampleRate: int(self.sampleRate),
                        samples: samples)

proc registerProc*(vm: var VM, word: string, vmProc: proc(vm: var VM)) =
  vm.words[word] = VMProcObj(vmProc: vmProc)
