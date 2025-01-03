#!/bin/bash

TEST_USERS=(
    "testuser" 
    "testuser1" 
    "testuser2" 
    "testuser3"
    )
PASSWORD="Password123!"
EXPIRY_DAYS=5 

for TEST_USER in "${TEST_USERS[@]}"; do
    if id "$TEST_USER" &>/dev/null; then
        echo "User $TEST_USER already exists. Removing and recreating..."
        sudo userdel -r "$TEST_USER"
    fi

    echo "Creating user $TEST_USER..."
    sudo useradd -m "$TEST_USER"

    echo "$TEST_USER:$PASSWORD" | sudo chpasswd
    echo "Password set for user $TEST_USER."

    sudo chage -E $(date -d "+$EXPIRY_DAYS days" +%Y-%m-%d) "$TEST_USER"
    echo "Password expiry set to $(date -d "+$EXPIRY_DAYS days" +%Y-%m-%d) for user $TEST_USER."

    echo "User $TEST_USER created successfully."
    sudo chage -l "$TEST_USER"
done
