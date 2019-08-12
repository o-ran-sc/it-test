export C_INCLUDE_PATH=$HOME/usr/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/usr/lib
export RMR_SEED_RT=$HOME/global_rmr_files/global_rmr_routes.rt
gcc pendulum_xapp.c -g -o pendulum_xapp -L $HOME/usr/lib -lrmr_nng -lnng -lpthread -lm

export PENDULUM_XAPP_RMR_RCV_PORT=5560
export DEMO_SENDER_PTO=1			# poll timeout listening for replies

export PRINT_FREQ=1000 #frequency at which test stats will be printed

RMR_RCV_ACK=1 ./pendulum_xapp $PRINT_FREQ;  # receiver that will ack every sender message
