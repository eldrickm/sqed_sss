#! /bin/bash
cd /rsghome/eldrick/sqed_sss/demos/vscale_demo_shashank
export ZI_MPI_EXEC_LOADED=1
/cad/mentor/qformal/linux_x86_64/lib/mpiexec -errfile-pattern /rsgs/pool0/eldrick/sqed_sss/demos/vscale_demo_shashank/output/qcache/FORMAL/NET/master.stderr -n 1 /cad/mentor/qformal/linux_x86_64/bin/qverifyfk -jobs 4 -od output -tool prove -init test.init -rtl_init_values -effort unlimited -import_db output/formal_compile.db -netcache /rsgs/pool0/eldrick/sqed_sss/demos/vscale_demo_shashank/output/qcache/FORMAL/NET -mode master < /dev/null 
