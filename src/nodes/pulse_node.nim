import math

import ../vm
import audio_node
import float_node

type PulseNode* = ref object of AudioNode
  freq: AudioNode
  width: AudioNode
  phase: float

method nchannels*(self: PulseNode): int = 1

method process*(self: PulseNode, vm: var VM) =
  let width = vm.next(self.width)[0]
  if self.phase < width:
    self.frame[0] = -1.0
  else:
    self.frame[0] = 1.0
  let freq = vm.next(self.freq)[0]
  let phaseIncrement = 1.0 / (vm.sampleRate / freq)
  self.phase += phaseIncrement
  self.phase = self.phase mod 1.0

proc doPulse*(vm: var VM) =
  let freq = AudioNode(vm.pop())
  let width = AudioNode(vm.getVar("width", 0.5))
  let phase: float = FloatNode(vm.getVar("phase", 0))
  vm.push(PulseNode(freq: freq, width: width, phase: phase))
