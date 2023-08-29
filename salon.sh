#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon -t -c"

echo "~~~~~ MY SALON ~~~~~"

MAIN_MENU() {

  if [[ -z $1 ]]
  then
    echo -e "\nWelcome to My Salon, what can I do for you today?"
  else
    echo -e "\n$1"
  fi

  LIST_SERVICES=$($PSQL "SELECT * FROM services")

  echo "$LIST_SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED != 1 && $SERVICE_ID_SELECTED != 2 && $SERVICE_ID_SELECTED != 3 ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_INFO=$($PSQL "SELECT name, customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_INFO ]]
    then
      echo -e "\nWhat is your name?"
      read CUSTOMER_NAME

      NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    echo -e "\nWhat time would you like to make your appointment?"
    read SERVICE_TIME

    APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    echo -e "\nI have put you down for a $(echo $SERVICE | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
}

MAIN_MENU
