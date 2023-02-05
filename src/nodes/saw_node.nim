import math

import ../vm
import audio_node

type SawNode* = ref object of AudioNode
  freq: AudioNode
  phase: float

method nchannels*(self: SawNode): int = 1

method process*(self: SawNode, vm: var VM) =
  self.frame[0] = -1.0 + self.phase * 2.0
  let freq = vm.next(self.freq)[0]
  let phaseIncrement = 1.0 / (vm.sampleRate / freq)
  self.phase += phaseIncrement
  self.phase = self.phase mod 1.0

proc doSaw*(vm: var VM) =
  let freq: AudioNode = vm.pop
  let phase: float = vm.getVar("phase", 0)
  vm.push(SawNode(freq: freq, phase: phase))
