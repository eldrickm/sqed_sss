# Copy relevant source files to the design folder
cp ./steelcore/rtl/*.v design/
cp ./steelcore/rtl/*.vh design/

# Patch design files
cp ./patches/wire_up/design_top.v design/
cp ./patches/wire_up/steel_top.v design/

# Write design files to design file list
ls ./design/ | sed 's/^/.\/design\//; s/$//' > ./design/design.flist
sed -i '/.\/design\/design.flist/d' ./design/design.flist

# Write qed files to design file list
echo "" >> ./design/design.flist
ls ./qed/ | sed 's/^/.\/qed\//; s/$//' >> ./design/design.flist
