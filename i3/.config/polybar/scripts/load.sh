#!/bin/bash
echo "load: $(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}')"
