#!/bin/bash

SCRIPT_DIR="/shell_scripts"  # Change this to your target folder

echo "|================================================================================|"
echo "|  Executing all .sh scripts in: ${shell_scripts}  "
echo "|================================================================================|"



for script in "$SCRIPT_DIR"/*.sh; do
  if [ -f "$script" ]; then
    echo "Running $script..."
    chmod +x "$script"    # Make sure it's executable
    source "$script"
  fi
done




