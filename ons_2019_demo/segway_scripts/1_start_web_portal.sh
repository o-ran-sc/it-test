  
E2SIM_DIR=$HOME/test/simulators/e2sim
ONS_DIR=$HOME/test/ons_2019_demo

echo "Initializing display variables.."
  echo 0 > $ONS_DIR/a1_med/a1_med_http_server/delay.txt 
  echo 0 > $ONS_DIR/a1_med/a1_med_http_server/load.txt 
  echo "{\"latency\":0, \"ricload\":0, \"load\":0, \"time\":0}" > $ONS_DIR/a1_med/a1_med_http_server/metrics.json 

  #7. a1 med http server
  cd $HOME/test/ons_2019_demo/a1_med/a1_med_http_server && ./a1med.py &
  sleep 5

  #6. dash_board
 # cd  $HOME/test/ons_2019_demo/dashboard && docker-compose -f docker-compose_v3.yml up &

 cd  $HOME/test/ons_2019_demo/dashboard && docker-compose -f docker-compose.yml up &


  sleep 5



