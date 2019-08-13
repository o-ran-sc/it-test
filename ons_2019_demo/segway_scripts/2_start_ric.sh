#!/bin/bash
#Bring up all components for ONS demo
clear

echo "Starting up all components for ONS 2019 Pendulum-control Demo"

E2SIM_DIR=$HOME/test/simulators/e2sim
ONS_DIR=$HOME/test/ons_2019_demo

#clean variables


function main()
{
  #Kill all running process
  #pkill -f start_demo
  pkill -f e2sim
  pkill -f pendulum_xapp

  #1. e2agent
  cd $E2SIM_DIR && ./build/e2sim  & 

  #2. pendulum xapp
  cd $HOME/test/ons_2019_demo/pendulum_xapp/ && bash build_and_run_pendulum_xapp.sh &
  sleep 2

  #3. e2 termination
  cd $HOME/test/simulators/e2sim &&  bash run_e2_term &
  sleep 2

  # #4. load consumer
  cd $HOME/test/ons_2019_demo/load_consumer && bash build &
  sleep 2


  # #5. load_gen
  cd $HOME/test/ons_2019_demo/load_gen && bash build &

  #7. a1 med http server
#  cd $HOME/test/ons_2019_demo/a1_med/a1_med_http_server && ./a1med.py &
#  sleep 3

  #6. dash_board
#  cd  $HOME/test/ons_2019_demo/dashboard && docker-compose up &
#  sleep 5


  #8. a1 med
  cd $HOME/test/ons_2019_demo/a1_med && bash build_and_run_dummy_a1_med.sh

}

main "$@"
echo "DEMO IS NOW UP AND RUNNING!!!!"
