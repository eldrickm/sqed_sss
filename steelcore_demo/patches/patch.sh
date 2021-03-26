# Copy relevant source files to the design folder
cp ./steelcore/rtl/*.v design/
cp ./steelcore/rtl/*.vh design/

# Write design file list
ls ./design/ | sed 's/^/.\/design\//; s/$//' > ./design/design.flist
sed -i '/.\/design\/design.flist/d' ./design/design.flist
