# Copy relevant source files to the design folder
# e.g. cp ./steelcore/rtl/*.v design/

# Patch design files
# e.g. cp ./patches/wire_up/design_top.v design/

# Write design files to design file list
# e.g. ls ./design/ | sed 's/^/.\/design\//; s/$//' > ./design/design.flist
# e.g. sed -i '/.\/design\/design.flist/d' ./design/design.flist

# Write qed files to design file list
# e.g. echo "" >> ./design/design.flist
# e.g. ls ./qed/ | sed 's/^/.\/qed\//; s/$//' >> ./design/design.flist
