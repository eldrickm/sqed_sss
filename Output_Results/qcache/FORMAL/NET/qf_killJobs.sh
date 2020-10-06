#! /bin/bash
cd /rsghome/esingh/pool0-esingh/trojan_demos/vscale_counter_sss
touch /rsgs/pool0/esingh/trojan_demos/vscale_counter_sss/Output_Results/qcache/FORMAL/NET/qf_killJobs.LOCK
for j in "19175 19184 19192 19200"
  do
  kill -s TERM  $j
  done
usrJobList=`cat /rsgs/pool0/esingh/trojan_demos/vscale_counter_sss/Output_Results/qcache/FORMAL/NET/user_joblist`
for j in "${usrJobList[@]}"
  do
    if [ "$j" != "" ] 
    then
      kill -s TERM  $j
    fi 
  done
rm -f /rsgs/pool0/esingh/trojan_demos/vscale_counter_sss/Output_Results/qcache/FORMAL/NET/qf_killJobs.LOCK > /dev/null
