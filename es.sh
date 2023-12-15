#!/bin/bash

if [ $# -lt 1 ]
then
  echo "USAGE:es.sh {start|stop}"
  exit
fi

case $1 in
"start")
  #start  ES
  for i in hadoop102 hadoop103 hadoop104
  do
    ssh $i nohup /opt/module/es7/bin/elasticsearch >/dev/null 2>&1 &
  done

  #start Kibana
  ssh hadoop102 nohup /opt/module/kibana7/bin/kibana >/dev/null 2>&1 &
;;
"stop")
  #stop Kibana
  ssh hadoop102 "sudo netstat -nltp | grep 5601 | awk '{print \$7}' | awk -F / '{print \$1}' | xargs -n1 kill"

  #stop ES
  for i in hadoop102 hadoop103 hadoop104
  do
    ssh $i "jps | grep Elasticsearch | awk '{print \$1}'| xargs -n1 kill" >/dev/null 2>&1
  done
;;
*)
  echo "USAGE:es.sh {start|stop}"
  exit
;;
esac
