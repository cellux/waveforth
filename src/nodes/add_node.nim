import ../vm
import audio_node

type AddNode* = ref object of AudioNode
  lhs: AudioNode
  rhs: AudioNode

method nframes*(self: AddNode): int =
  let l = self.lhs.nframes
  let r = self.rhs.nframes
  if l == 0:
    result = r
  elif r == 0:
    result = l
  else:
    result = min(l, r)

method nchannels*(self: AddNode): int =
  max(self.lhs.nchannels, self.rhs.nchannels)

method process*(self: AddNode, vm: var VM) =
  let lhsFrame = vm.next(self.lhs)
  let rhsFrame = vm.next(self.rhs)
  if self.rhs.nchannels == 1:
    for i in 0..<self.lhs.nchannels:
      self.frame[i] = lhsFrame[i] + rhsFrame[0]
  else:
    for i in 0..<self.lhs.nchannels:
      self.frame[i] = lhsFrame[i] + rhsFrame[i]

proc doAdd*(vm: var VM) =
  var rhs: AudioNode = vm.pop
  var lhs: AudioNode = vm.pop
  if lhs.nchannels == 1 and rhs.nchannels == 2:
    swap(lhs, rhs)
  vm.push(AddNode(lhs: lhs, rhs: rhs))
