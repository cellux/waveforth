import ../vm
import audio_node
import float_node

type LineNode* = ref object of AudioNode
  startValue: float
  endValue: float
  length: int
  value: float
  increment: float

method nframes*(self: LineNode): int = self.length
method nchannels*(self: LineNode): int = 1

method process*(self: LineNode, vm: var VM) =
  self.frame[0] = self.value
  self.value += self.increment

proc doLine*(vm: var VM) =
  let length: int = FloatNode(vm.pop)
  assert length > 0
  let endValue: float = FloatNode(vm.pop)
  let startValue: float = FloatNode(vm.pop)
  let value = startValue
  let increment: float = (endValue - startValue) / float(length)
  vm.push(LineNode(startValue: startValue,
                   endValue: endValue,
                   length: length,
                   value: value,
                   increment: increment))
