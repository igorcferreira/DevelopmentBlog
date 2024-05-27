#!/bin/bash

PORT="8000"
DIRECTORY="$(pwd)/Build"

while [ -n "$1" ]; do
    case "$1" in
      --port | -p) PORT="$2" && shift ;;
      --directory | -d) DIRECTORY="$2" && shift ;;
    esac
    shift
done

kill "$(lsof -t -i "tcp:$PORT")" & \
python3 -m http.server -d "$DIRECTORY" "$PORT" & \
sleep .01 && \
open "http://localhost:$PORT"
