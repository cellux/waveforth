import math

import ../vm
import audio_node
import float_node

type SinNode* = ref object of AudioNode
  freq: AudioNode
  phase: float

method nchannels*(self: SinNode): int = 1

method process*(self: SinNode, vm: var VM) =
  self.frame[0] = math.sin(self.phase * 2 * PI)
  let freq = vm.next(self.freq)[0]
  let phaseIncrement = 1.0 / (vm.sampleRate / freq)
  self.phase += phaseIncrement
  self.phase = self.phase mod 1.0

proc doSin*(vm: var VM) =
  let freq = AudioNode(vm.pop)
  let phase: float = FloatNode(vm.getNode(":phase", 0))
  vm.push(SinNode(freq: freq, phase: phase))
