#!/bin/bash
### In postfix.sh (make sure this file is chmod +x):
# `chpst -u root` runs the given command as the user `xxxxx`.
# If you omit that part, the command will be run as root.

exec chpst -u root /usr/lib/postfix/master -d -c /etc/postfix 2>&1
