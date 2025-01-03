#!/bin/bash

set -o pipefail

USERS_TO_DELETE=(
    "testuser" 
    "testuser1" 
    "testuser2" 
    "testuser3"
    )

for USER in "${USERS_TO_DELETE[@]}"; do
    if id "$USER" &>/dev/null; then
        echo "Deleting user: $USER"
        sudo userdel -r "$USER"
        echo "User $USER deleted successfully."
    else
        echo "User $USER does not exist."
    fi
done


