import ../vm
import audio_node

type
  FloatNode* = ref object of AudioNode
    value*: float

method nchannels*(self: FloatNode): int = 1

method process*(self: FloatNode, vm: var VM) =
  self.frame[0] = self.value

func makeNode*(value: float): FloatNode = FloatNode(value: value)
func makeNode*(value: int): FloatNode = FloatNode(value: float(value))

converter toFloat*(self: FloatNode): float = self.value
converter toInt*(self: FloatNode): int = int(self.value)
