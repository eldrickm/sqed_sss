
analyze -sv09 -f vscale_jg.flist toppipe.v
elaborate -disable_auto_bbox -top toppipe
clock clk
reset -expression reset


