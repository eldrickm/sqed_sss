#! /bin/bash
cd /rsghome/eldrick/sqed_sss/demos/vscale_demo_shashank
export ZI_MPI_EXEC_LOADED=1
trap 'disown $PID ; kill -KILL $PID' TERM INT
/cad/mentor/qformal/linux_x86_64/lib/mpiexec -n 1 /cad/mentor/qformal/linux_x86_64/bin/qverifyfk -od output -tool prove -init test.init -rtl_init_values -effort unlimited -import_db output/formal_compile.db -mode slave -slave_id 3 -mpiport 'tag#0$port#38646$description#rsg10.stanford.edu$ifname#172.24.74.106$' < /dev/null &
PID=$!
wait ${PID}
wait ${PID}
if [ "$?" -ne "0" ]; then 
  /cad/mentor/qformal/linux_x86_64/lib/mpiexec -n 1 /cad/mentor/qformal/linux_x86_64/bin/qverifyfk -od output -tool prove -init test.init -rtl_init_values -effort unlimited -import_db output/formal_compile.db -mode slave -slave_id 3 -mpiport 'tag#0$port#38646$description#rsg10.stanford.edu$ifname#172.24.74.106$' -monitor < /dev/null
fi
