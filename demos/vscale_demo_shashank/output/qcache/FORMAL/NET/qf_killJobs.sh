#! /bin/bash
cd /rsghome/eldrick/sqed_sss/demos/vscale_demo_shashank
touch /rsgs/pool0/eldrick/sqed_sss/demos/vscale_demo_shashank/output/qcache/FORMAL/NET/qf_killJobs.LOCK
for j in "4210 4216 4225 4236"
  do
  kill -s TERM  $j
  done
usrJobList=`cat /rsgs/pool0/eldrick/sqed_sss/demos/vscale_demo_shashank/output/qcache/FORMAL/NET/user_joblist`
for j in "${usrJobList[@]}"
  do
    if [ "$j" != "" ] 
    then
      kill -s TERM  $j
    fi 
  done
rm -f /rsgs/pool0/eldrick/sqed_sss/demos/vscale_demo_shashank/output/qcache/FORMAL/NET/qf_killJobs.LOCK > /dev/null
