pkill -f pendulum_xapp
pkill -f e2sim #kills both agent and term
pkill -f dummy #kills a1 med C code and load consumer
pkill -f load_gen
pkill -f a1med #kills a1 mediator http server
docker kill $(docker ps -q) #kills dashboard
