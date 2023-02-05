import ../vm
import ../types

type
  AudioNode* = ref object of VMObj
    tick*: int
    frame*: Frame

method nframes*(self: AudioNode): int {.base.} = 0

method nchannels*(self: AudioNode): int {.base.} =
  raise newException(Defect, "nchannels not implemented")

method process*(self: AudioNode, vm: var VM) {.base.} =
  raise newException(Defect, "process not implemented")
