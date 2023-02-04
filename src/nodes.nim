import vm

import nodes/add_node
import nodes/mul_node
import nodes/div_node
import nodes/line_node
import nodes/sin_node
import nodes/saw_node
import nodes/pulse_node
import nodes/take_node

proc registerNodes*(vm: var VM) =
  vm.registerProc("+", doAdd)
  vm.registerProc("*", doMul)
  vm.registerProc("/", doDiv)
  vm.registerProc("line", doLine)
  vm.registerProc("sin", doSin)
  vm.registerProc("saw", doSaw)
  vm.registerProc("pulse", doPulse)
  vm.registerProc("take", doTake)
