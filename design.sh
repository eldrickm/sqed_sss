#!/bin/csh

set VLIB = $QHOME/modeltech/plat/vlib
set VMAP = $QHOME/modeltech/plat/vmap
set VLOG = $QHOME/modeltech/plat/vlog

echo "Compiling ridecore design"

mkdir Output_Results

$VLOG +define+FORMAL_TOOL +define+NOINITMEM +define+INITIALIZERO toppipe.v vscale_checker_bind.sv vscale_checker.sv  -f ./vscale.flist -l Output_Results/vlog.rpt

