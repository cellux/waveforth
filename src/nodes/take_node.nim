import ../vm
import audio_node
import float_node

type TakeNode* = ref object of AudioNode
  nframes*: int
  source*: AudioNode

method nframes*(self: TakeNode): int = self.nframes
method nchannels*(self: TakeNode): int = self.source.nchannels

method process*(self: TakeNode, vm: var VM) =
  self.frame = vm.next(self.source)

proc doTake*(vm: var VM) =
  let nframes: int = FloatNode(vm.pop)
  let source = AudioNode(vm.pop)
  vm.push(TakeNode(nframes: nframes, source: source))
