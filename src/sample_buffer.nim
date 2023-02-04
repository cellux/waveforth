import std/os
import std/bitops

import sndfile

import types

type SampleBuffer* = ref object
  nchannels*: int
  nframes*: int
  sampleRate*: int
  samples*: seq[Sample]

proc save*(self: SampleBuffer, filename: string) =
  let filename = filename.changeFileExt("wav")
  let extPos = filename.searchExtPos()
  let ext = filename.substr(extPos+1)
  let format = case ext
    of "wav": bitor(SF_FORMAT_WAV, SF_FORMAT_PCM_16)
    else:
      raise newException(ValueError, "unknown format: " & ext)
  var info: SF_INFO
  info.samplerate = cint(self.sampleRate)
  info.channels = cint(self.nchannels)
  info.format = cint(format)
  var sndfile = sf_open(cstring(filename), cint(SFM_WRITE), addr(info))
  if sndfile == nil:
    raise newException(Defect, "sf_open failed:" & $sf_strerror(nil))
  defer: discard sf_close(sndfile)
  let framesWritten = sf_writef_double(sndfile, addr(self.samples[0]), self.nframes)
  assert framesWritten == self.nframes
