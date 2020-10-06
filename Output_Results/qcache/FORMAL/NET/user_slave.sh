#! /bin/bash
cd /rsghome/esingh/pool0-esingh/trojan_demos/vscale_counter_sss
export ZI_MPI_EXEC_LOADED=1
SLAVE_ID=0
SLAVE_ID=`/cad/mentor/qformal/linux_x86_64/lib/mpiexec -n 1 /cad/mentor/qformal/linux_x86_64/bin/qverifyfk -od Output_Results -tool prove -init test.init -rtl_init_values -effort unlimited -import_db Output_Results/formal_compile.db -mode slave -mpiport 'tag#0$port#37719$description#rsg9.stanford.edu$ifname#172.24.74.107$' -launcher < /dev/null | grep USER_SLAVEID | awk -F\= '{print $2}' ` 
if [ "X${SLAVE_ID}" != "X0" ] 
then 
 trap 'kill -TERM $PID' TERM INT
 /cad/mentor/qformal/linux_x86_64/lib/mpiexec -n 1 /cad/mentor/qformal/linux_x86_64/bin/qverifyfk -od Output_Results -tool prove -init test.init -rtl_init_values -effort unlimited -import_db Output_Results/formal_compile.db -mode slave -mpiport 'tag#0$port#37719$description#rsg9.stanford.edu$ifname#172.24.74.107$' -slave_id ${SLAVE_ID} < /dev/null &
 PID=$!
 wait ${PID}
 wait ${PID}
 if [ "$?" -ne "0" ]; then 
   /cad/mentor/qformal/linux_x86_64/lib/mpiexec -n 1 /cad/mentor/qformal/linux_x86_64/bin/qverifyfk -od Output_Results -tool prove -init test.init -rtl_init_values -effort unlimited -import_db Output_Results/formal_compile.db -mode slave -mpiport 'tag#0$port#37719$description#rsg9.stanford.edu$ifname#172.24.74.107$' -monitor < /dev/null 
 fi
fi
