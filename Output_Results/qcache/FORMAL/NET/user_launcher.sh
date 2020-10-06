#! /bin/bash
cd /rsghome/esingh/pool0-esingh/trojan_demos/vscale_counter_sss
export ZI_MPI_EXEC_LOADED=1
usrJobId=0
setsid /rsgs/pool0/esingh/trojan_demos/vscale_counter_sss/Output_Results/qcache/FORMAL/NET/user_slave.sh &
usrJobId=$!
echo $usrJobId >> /rsgs/pool0/esingh/trojan_demos/vscale_counter_sss/Output_Results/qcache/FORMAL/NET/user_joblist
