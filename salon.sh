#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -X -q -t -A"

list_services() {
  $PSQL -c "SELECT service_id || ') ' || name FROM services ORDER BY service_id;"
}

printf '\n~~~~~ MY SALON ~~~~~\n\n'
printf 'Welcome to My Salon, how can I help you?\n\n'
list_services

while true; do
  read SERVICE_ID_SELECTED

  if [[ "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]; then
    SERVICE_NAME=$($PSQL -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  else
    SERVICE_NAME=""
  fi

  if [[ -n "$SERVICE_NAME" ]]; then
    break
  fi

  printf "\nI could not find that service. What would you like today?\n"
  list_services
done

printf "\nWhat's your phone number?\n"
read CUSTOMER_PHONE
CUSTOMER_PHONE_SQL=${CUSTOMER_PHONE//\'/\'\'}
CUSTOMER_ID=$($PSQL -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE_SQL';")

if [[ -z "$CUSTOMER_ID" ]]; then
  printf "\nI don't have a record for that phone number, what's your name?\n"
  read CUSTOMER_NAME
  CUSTOMER_NAME_SQL=${CUSTOMER_NAME//\'/\'\'}
  CUSTOMER_ID=$($PSQL -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME_SQL', '$CUSTOMER_PHONE_SQL') RETURNING customer_id;")
else
  CUSTOMER_NAME=$($PSQL -c "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
fi

printf '\nWhat time would you like your %s, %s?\n' "$SERVICE_NAME" "$CUSTOMER_NAME"
read SERVICE_TIME
SERVICE_TIME_SQL=${SERVICE_TIME//\'/\'\'}
$PSQL -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME_SQL');" >/dev/null

printf '\nI have put you down for a %s at %s, %s.\n' "$SERVICE_NAME" "$SERVICE_TIME" "$CUSTOMER_NAME"