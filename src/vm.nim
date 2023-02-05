import std/tables
import std/strutils

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
    vars: Table[string, VMObj]
    stack: seq[VMObj]
    sampleRate*: float
    tick: int

proc push*(self: var VM, value: VMObj) =
  self.stack.add(value)

proc pop*(self: var VM): VMObj =
  self.stack.pop()

proc top*(self: var VM): VMObj =
  let length = len(self.stack)
  self.stack[length-1]

func getVar*(self: var VM, name: string): VMObj =
  self.vars[name]

func getVar*[T](self: var VM, name: string, default: T): VMObj =
  try:
    return self.getVar(name)
  except KeyError:
    return VMObj(default)

func setVar*(self: var VM, name: string, value: VMObj) =
  self.vars[name] = value

import nodes/audio_node

proc next*(vm: var VM, node: AudioNode): Frame =
  if node.tick == vm.tick:
    node.process(vm)
    inc(node.tick)
  node.frame

import nodes/float_node

converter toObj*(value: float): VMObj = FloatNode(value: value)
converter toFloat*(self: VMObj): float = FloatNode(self).value

converter toObj*(value: int): VMObj = FloatNode(value: float(value))
converter toInt*(self: VMObj): int = int(FloatNode(self).value)

proc processWord*(self: var VM, word: string) =
  if word.startsWith(':'):
    let name = word.substr(1)
    self.setVar(name, self.pop)
  elif word.endsWith(':'):
    let name = word.substr(0, word.high)
    self.push(self.getVar(name))
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
        self.push(VMObj(x))
      except ValueError:
        raise newException(SyntaxError, "cannot understand: " & word)

proc nextWord*(self: var VM): string =
  result = self.input[self.inputIndex]
  inc(self.inputIndex)

proc processWords*(self: var VM, input: seq[string]) =
  self.input = input
  self.inputIndex = 0
  while self.inputIndex < len(self.input):
    self.processWord(self.nextWord)

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
  SampleBuffer(nchannels: nchannels,
               nframes: nframes,
               sampleRate: int(self.sampleRate),
               samples: samples)

proc registerProc*(vm: var VM, word: string, vmProc: VMProc) =
  vm.words[word] = VMProcObj(vmProc: vmProc)
