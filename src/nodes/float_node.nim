import ../vm
import audio_node

type
  FloatNode* = ref object of AudioNode
    value*: float

method nchannels*(self: FloatNode): int = 1

method process*(self: FloatNode, vm: var VM) =
  self.frame[0] = self.value
