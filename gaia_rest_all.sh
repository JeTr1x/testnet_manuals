


#!/bin/bash

echo "Рестарт всех контейнеров gaianet-node-..."

for i in $(seq 1 30); do
  CONTAINER_NAME="gaianet-node-$i"
  if docker ps -q -f name="^/${CONTAINER_NAME}$" > /dev/null; then
    echo "Перезапускаю $CONTAINER_NAME..."
    docker restart "$CONTAINER_NAME"
    sleep 90
  else
    echo "$CONTAINER_NAME не запущен."
  fi
done
docker ps -a
