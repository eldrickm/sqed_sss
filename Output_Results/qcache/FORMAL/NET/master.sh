#! /bin/bash
cd /rsghome/esingh/pool0-esingh/trojan_demos/vscale_counter_sss
export ZI_MPI_EXEC_LOADED=1
/cad/mentor/qformal/linux_x86_64/lib/mpiexec -errfile-pattern /rsgs/pool0/esingh/trojan_demos/vscale_counter_sss/Output_Results/qcache/FORMAL/NET/master.stderr -n 1 /cad/mentor/qformal/linux_x86_64/bin/qverifyfk -jobs 4 -od Output_Results -tool prove -init test.init -rtl_init_values -effort unlimited -import_db Output_Results/formal_compile.db -netcache /rsgs/pool0/esingh/trojan_demos/vscale_counter_sss/Output_Results/qcache/FORMAL/NET -mode master < /dev/null 
