import ../vm
import audio_node

type MulNode* = ref object of AudioNode
  lhs: AudioNode
  rhs: AudioNode

method nframes*(self: MulNode): int = self.rhs.nframes
method nchannels*(self: MulNode): int = self.lhs.nchannels

method process*(self: MulNode, vm: var VM) =
  let lhsFrame = vm.next(self.lhs)
  let rhsFrame = vm.next(self.rhs)
  for i in 0..<self.lhs.nchannels:
    self.frame[i] = lhsFrame[i] * rhsFrame[0]

proc doMul*(vm: var VM) =
  var rhs = AudioNode(vm.pop)
  var lhs = AudioNode(vm.pop)
  if rhs.nchannels != 1:
    if lhs.nchannels != 1:
      raise newException(Defect, "* needs at least one mono operand")
    else:
      swap(lhs, rhs)
  vm.push(MulNode(lhs: lhs, rhs: rhs))
