# the result folder created with nix-build
while [ -n "$1" ]
do
case "$1" in
--gofer)
cp -v $2 $(pwd)/result/share/gofer.json
cp -v $2 $(pwd)/result/share/gofer_temp.json
export GOFER_CONFIG=$2
# The result-3 directory is created by nix and it is a symbolic link of nix's installed package, which contain spire , gofer, ghost, keeman etc

export GOFER_PATH=$(pwd)/result-3/bin/gofer
shift
  ;;
--omnia) 
sudo cp $2 $(pwd)/result/share/relay--relay.json
sudo cp $2 $(pwd)/result/share/relay--relay-temp.json 
export OMNIA_CONFIG=$2
export OMNIA_VERBOSE=true
# The result-2 directory is created by nix and it is a symbolic link of nix's installed package, which contain omnia
export OMNIA_PATH=$(pwd)/result-2/bin/omnia
shift
;;
--spire) 
sudo cp -v $2 $(pwd)/result/share/spire.json
sudo cp -v $2 $(pwd)/result/share/spire-temp.json
export SPIRE_CONFIG=$2
# The result-3 directory is created by nix and it is a symbolic link of nix's installed package, which contain spire , gofer, ghost, keeman etc
export SPIRE_PATH=$(pwd)/result-3/bin/spire
export SPIRE_LOG_VERBOSITY=debug
shift
 ;;
--) shift
break ;;
*) echo "$1 is not an option";;
esac
shift
done

export SETZER_MIN_MEDIAN=1
$(pwd)/result/bin/install-relay relay
sudo cp -v  $(pwd)/result/share/spire-temp.json $SPIRE_CONFIG
sudo cp -v  $(pwd)/result/share/relay--relay-temp.json $OMNIA_CONFIG
sudo cp -v  $(pwd)/result/share/gofer_temp.json $GOFER_CONFIG
