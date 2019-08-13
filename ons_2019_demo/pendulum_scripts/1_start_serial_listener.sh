E2SIM_DIR=$HOME/test/simulators/e2sim
echo "Initialize conduit file to zero.."
echo "\$0#" > $E2SIM_DIR/arduino_delay.txt
cd $E2SIM_DIR && ./build/serial_listener & 
sleep 5
