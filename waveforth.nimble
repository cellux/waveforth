# Package

version       = "0.1.0"
author        = "Ruzsa Balazs"
description   = "A Forth dialect for audio generation"
license       = "MIT"
srcDir        = "src"
bin           = @["waveforth"]

# Dependencies

requires "nim >= 1.6.10"
requires "futhark >= 0.6.1"
requires "cligen >= 1.5"
