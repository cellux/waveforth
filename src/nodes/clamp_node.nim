import ../vm
import ../types
import audio_node

type ClampNode* = ref object of AudioNode
  source: AudioNode
  lo: Sample
  hi: Sample

method nframes*(self: ClampNode): int = self.source.nframes
method nchannels*(self: ClampNode): int = self.source.nchannels

method process*(self: ClampNode, vm: var VM) =
  let sourceFrame = vm.next(self.source)
  for i in 0..<self.source.nchannels:
    self.frame[i] = sourceFrame[i].clamp(self.lo, self.hi)

proc doClamp*(vm: var VM) =
  var hi: float = vm.pop
  var lo: float = vm.pop
  var source: AudioNode = vm.pop
  if lo > hi:
    swap(lo, hi)
  vm.push(ClampNode(source: source, lo: lo, hi: hi))
