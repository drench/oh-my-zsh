dockerenv=$(docker-machine env default)

if [ "$dockerenv" ]; then
  eval $dockerenv
fi
