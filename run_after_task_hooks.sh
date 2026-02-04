#!/usr/bin/env bash

sed -i 's/^DEFAULT_TIME\s=\stime(22,0,0)/DEFAULT_TIME = time(18,0,0)/' ~/.task/hooks/default-time/pirate_add_default_time.py

