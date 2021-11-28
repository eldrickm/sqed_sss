#! /bin/bash
cd /rsghome/eldrick/sqed_sss/demos/vscale_demo_shashank
export ZI_MPI_EXEC_LOADED=1
usrJobId=0
setsid /rsgs/pool0/eldrick/sqed_sss/demos/vscale_demo_shashank/output/qcache/FORMAL/NET/user_slave.sh &
usrJobId=$!
echo $usrJobId >> /rsgs/pool0/eldrick/sqed_sss/demos/vscale_demo_shashank/output/qcache/FORMAL/NET/user_joblist
