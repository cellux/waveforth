import ../vm
import ../types
import audio_node

type DivNode* = ref object of AudioNode
  lhs: AudioNode
  rhs: AudioNode

method nframes*(self: DivNode): int = self.rhs.nframes
method nchannels*(self: DivNode): int = self.lhs.nchannels

method process*(self: DivNode, vm: var VM) =
  let lhsFrame = vm.next(self.lhs)
  let rhsFrame = vm.next(self.rhs)
  for i in 0..<self.lhs.nchannels:
    if rhsFrame[0] == 0:
      self.frame[i] = 0
    else:
      self.frame[i] = lhsFrame[i] / rhsFrame[0]

proc doDiv*(vm: var VM) =
  var rhs: AudioNode = vm.pop
  var lhs: AudioNode = vm.pop
  if rhs.nchannels != 1:
    raise newException(SyntaxError, "/ needs a mono operand on the right side")
  vm.push(DivNode(lhs: lhs, rhs: rhs))
