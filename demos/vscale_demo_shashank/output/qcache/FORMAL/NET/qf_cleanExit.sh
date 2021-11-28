#! /bin/bash
cd /rsghome/eldrick/sqed_sss/demos/vscale_demo_shashank
touch /rsgs/pool0/eldrick/sqed_sss/demos/vscale_demo_shashank/output/qcache/FORMAL/NET/qf_cleanExit.LOCK
export ZI_MPI_EXEC_LOADED=1
 /cad/mentor/qformal/linux_x86_64/lib/mpiexec -n 1 /cad/mentor/qformal/linux_x86_64/bin/qverifyfk  -od output -tool prove -init test.init -rtl_init_values -effort unlimited -import_db output/formal_compile.db -mode slave -slave_id 5 -force_shutdown -mpiport 'tag#0$port#38646$description#rsg10.stanford.edu$ifname#172.24.74.106$' < /dev/null 
rm -f /rsgs/pool0/eldrick/sqed_sss/demos/vscale_demo_shashank/output/qcache/FORMAL/NET/qf_cleanExit.LOCK > /dev/null
