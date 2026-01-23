#!/bin/bash

PORT="8000"

while [ -n "$1" ]; do
    case "$1" in
      --port | -p) PORT="$2" && shift ;;
    esac
    shift
done

kill "$(lsof -t -i "tcp:$PORT")"
