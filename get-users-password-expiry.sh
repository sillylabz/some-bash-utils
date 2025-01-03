#!/bin/bash

set -o pipefail

SERVER_HOSTNAME=$(hostname)
CURRENT_DATE=$(date +%s)
EXPIRY_THRESHOLD=$((7 * 86400))
existing_accounts=$(awk -F ':' '{print $1}' /etc/passwd)

EMAIL_RECIPIENTS=(
    "user-a40d9d67-fa43-411d-95e1-4fe98a69b317@mailslurp.biz"
    )
EMAIL_SUBJECT="Users with passwords expiring within the next 7 days on server $SERVER_HOSTNAME"
TEMP_EMAIL_BODY="/tmp/password_expiry_alert.txt"
TEMP_TABLE_HEADER="/tmp/temp_table_header.txt"


echo "Searching for users with passwords expiring within the next 7 days..."
echo ""

echo -e "| ACCOUNT        | EXPIRES        | REMAINING DAYS | LAST CHANGED     |" > "$TEMP_EMAIL_BODY"
echo -e "|----------------|----------------|----------------|------------------|" >> "$TEMP_EMAIL_BODY"

echo -e "| ACCOUNT        | EXPIRES        | REMAINING DAYS | LAST CHANGED     |" > "$TEMP_TABLE_HEADER"
echo -e "|----------------|----------------|----------------|------------------|" >> "$TEMP_TABLE_HEADER"


cat "$TEMP_TABLE_HEADER"

for account in $existing_accounts; do
    expires_string=$(sudo chage -l "$account" | grep 'Account expires' | awk '{print $4, $5, $6}')

    if [[ "$expires_string" == "never" || -z "$expires_string" ]]; then
        continue
    fi

    expires_date=$(date -d "$expires_string" +%s 2>/dev/null)

    if (( expires_date > CURRENT_DATE && expires_date - CURRENT_DATE <= EXPIRY_THRESHOLD )); then
        remaining_days=$(( (expires_date - CURRENT_DATE) / 86400 ))
        changed_date=$(sudo chage -l "$account" | grep 'Last password change' | awk '{print $5, $6, $7}')

        printf "| %-14s | %-14s | %-14s | %-16s |\n" "$account" "$expires_string" "$remaining_days" "$changed_date" >> "$TEMP_EMAIL_BODY"
        printf "| %-14s | %-14s | %-14s | %-16s |\n" "$account" "$expires_string" "$remaining_days" "$changed_date"
    fi
done

echo ""

if [[ $(wc -l < "$TEMP_EMAIL_BODY") -gt 2 ]]; then
    for EMAIL in "${EMAIL_RECIPIENTS[@]}"; do
        mailx -s "$EMAIL_SUBJECT" "$EMAIL" < "$TEMP_EMAIL_BODY"
    done
else
    echo "No users with expiring passwords within the next 7 days found."
fi


rm -f "$TEMP_EMAIL_BODY"
rm -f "$TEMP_TABLE_HEADER"
