#!/bin/csh

set VLIB = $QHOME/modeltech/plat/vlib
set VMAP = $QHOME/modeltech/plat/vmap
set VLOG = $QHOME/modeltech/plat/vlog

echo "Setting up workspace work"

$VLIB work
$VMAP work work

