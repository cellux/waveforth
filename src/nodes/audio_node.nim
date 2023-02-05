import ../vm
import ../types

type
  AudioNode* = ref object of VMObj
    tick*: int
    frame*: Frame

method nframes*(self: AudioNode): int {.base.} = 0

method nchannels*(self: AudioNode): int {.base.} =
  raise newException(NotImplementedError, "nchannels not implemented")

method process*(self: AudioNode, vm: var VM) {.base.} =
  raise newException(NotImplementedError, "process not implemented")

converter toAudioNode*(obj: VMObj): AudioNode = AudioNode(obj)
