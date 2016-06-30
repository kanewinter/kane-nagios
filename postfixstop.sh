#!/bin/bash
### In postfixstop.sh (make sure this file is chmod +x):
# `/sbin/setuser xxxxx` runs the given command as the user `xxxxx`.
# If you omit that part, the command will be run as root.

postfix stop
