import futhark

importc: "sndfile.h"

{.passC: gorge("pkgconf --cflags sndfile").}
{.passL: gorge("pkgconf --libs sndfile").}
