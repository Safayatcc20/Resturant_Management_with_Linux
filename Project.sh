#!/bin/bash

CASH_FILE="cash.txt"
MENU_FILE="menu.txt"
ORDERS_FILE="orders.txt"

if [ ! -f $CASH_FILE ]; then
    echo "0" > $CASH_FILE
fi

if [ ! -f $MENU_FILE ]; then
    touch $MENU_FILE
fi

if [ ! -f $ORDERS_FILE ]; then
    touch $ORDERS_FILE
fi

welcome_screen() {
    clear
    echo "---------------------------------"
    echo " Welcome to Restaurant Management System "
    echo "---------------------------------"
    echo
    echo "1. Admin Login"
    echo "2. Customer Login"
    echo "3. Exit"
    echo
    read -p "Please choose an option: " option
    case $option in
        1) admin_login ;;
        2) customer_login ;;
        3) exit_screen ;;
        *) echo "Invalid option!" ; welcome_screen ;;
    esac
}

admin_login() {
    clear
    read -p "Enter Admin Username: " admin_user
    read -s -p "Enter Admin Password: " admin_pass
    echo
    if [[ "$admin_user" == "admin" && "$admin_pass" == "pass" ]]; then
        admin_menu
    else
        echo "Invalid login details!"
        welcome_screen
    fi
}

admin_menu() {
    clear
    echo "-----------------------------"
    echo "        Admin Menu "
    echo "-----------------------------"
    echo
    echo "1. View Cash"
    echo "2. View Current Orders"
    echo "3. View Menu"
    echo "4. Add New Item to Menu"
    echo "5. Delete Item from Menu"
    echo "6. Edit Item from Menu"
    echo "7. Logout"
    echo
    read -p "Please choose an option: " option
    case $option in
        1) view_cash ;;
        2) view_orders ;;
        3) view_menu ;;
        4) add_item ;;
        5) delete_item ;;
        6) edit_item ;;
        7) welcome_screen ;;
        *) echo "Invalid option!" ; admin_menu ;;
    esac
}

view_cash() {
    clear
    echo "-----------------------------"
    echo "        Cash Balance "
    echo "-----------------------------"
    echo "Total Cash: "
    cat $CASH_FILE
    echo "-----------------------------"
    echo
    read -p "Press any key to return to Admin Menu..." key
    admin_menu
}

view_orders() {
    clear
    echo "-----------------------------"
    echo "      Current Orders "
    echo "-----------------------------"
    cat $ORDERS_FILE
    echo "-----------------------------"
    echo
    read -p "Press any key to return to Admin Menu..." key
    admin_menu
}

view_menu() {
    clear
    echo "-----------------------------"
    echo "           Menu "
    echo "-----------------------------"
    cat $MENU_FILE
    echo "-----------------------------"
    echo
    read -p "Press any key to return to Admin Menu..." key
    admin_menu
}

add_item() {
    clear
    if [ -s $MENU_FILE ]; then
        highest_item_number=$(awk -F ' - ' '{print $1}' $MENU_FILE | sort -n | tail -1)
    else
        highest_item_number=0
    fi
    new_item_number=$((highest_item_number + 1))
    
    read -p "Enter Item Name: " item_name
    read -p "Enter Item Description: " item_desc
    read -p "Enter Item Price: " item_price
    echo "Adding item: $new_item_number - $item_name - $item_desc - $item_price"
    echo "$new_item_number - $item_name - $item_desc - $item_price" >> $MENU_FILE

    echo
    echo "Item added to menu."
    echo
    read -p "Press any key to return to Admin Menu..." key
    
    admin_menu
}

delete_item() {
    clear
    echo "-----------------------------"
    echo " Menu "
    echo "-----------------------------"
    cat $MENU_FILE
    echo "-----------------------------"
    
    read -p "Enter the exact Item Number to delete: " item_number
    
    echo "Item number entered: '$item_number'"
    
    if grep -q "^$item_number - " $MENU_FILE; then
        echo "Item found. Deleting..."
        sed -i "/^$item_number -/d" $MENU_FILE
        awk '{ if ($1 > n) { $1 = $1 - 1 } print }' n="$item_number" $MENU_FILE > $MENU_FILE.tmp
        mv $MENU_FILE.tmp $MENU_FILE
        echo
        echo "Item deleted successfully."
    else
        echo "Error deleting item. Item number '$item_number' not found in menu."
    fi
    
    echo
    read -p "Press any key to return to Admin Menu..." key
    admin_menu
}

edit_item() {
    clear
    echo "-----------------------------"
    echo " Menu "
    echo "-----------------------------"
    cat $MENU_FILE
    echo "-----------------------------"
    
    read -p "Enter the exact Item Number to edit: " item_number
    
    echo "Item number entered: '$item_number'"
    
    if grep -q "^$item_number - " $MENU_FILE; 
    then
        echo "Item found. Editing..."

        tmp_file=$(mktemp)
        
        read -p "Enter new Item Name: " new_item_name
        read -p "Enter new Item Description: " new_item_desc
        read -p "Enter new Item Price: " new_item_price
        
        sed "/^$item_number -/d" $MENU_FILE > $tmp_file
        echo "$item_number - $new_item_name - $new_item_desc - $new_item_price" >> $tmp_file
        mv $tmp_file $MENU_FILE
        
        sort -n -o $MENU_FILE $MENU_FILE
        echo
        echo "Item edited successfully."
    else
        echo
        echo "Error editing item. Item number '$item_number' not found in menu."
    fi
    
    echo
    read -p "Press any key to return to Admin Menu..." key
    admin_menu
}


customer_login() {
    customer_menu
}

customer_menu() {
    clear
    echo "-----------------------------"
    echo "        Customer Menu "
    echo "-----------------------------"
    echo
    echo "1. View Menu"
    echo "2. Place Order"
    echo "3. View Order"
    echo "4. Cancel Order"
    echo "5. Exit"
    echo
    read -p "Please choose an option: " option
    case $option in
        1) view_menu_customer ;;
        2) place_order ;;
        3) view_orders_customer ;;
        5) cancel_order ;;
        4) welcome_screen ;;
        *) echo "Invalid option!" ; customer_menu ;;
    esac
}

view_menu_customer() {
    clear
    echo "-----------------------------"
    echo "           Menu "
    echo "-----------------------------"
    cat $MENU_FILE
    echo "-----------------------------"
    echo
    read -p "Press any key to return to Customer Menu..." key
    customer_menu
}

place_order() {
    clear
    echo "-----------------------------"
    echo "           Menu "
    echo "-----------------------------"
    cat $MENU_FILE
    echo "-----------------------------"
    echo

    read -p "Enter your Name: " customer_name
    read -p "Enter your Phone Number: " phone_number

    declare -A order_items
    total_price=0

    while true; do
        read -p "Enter Item Number to order (or 'done' to finish): " item_number
        if [[ $item_number == "done" ]]; then
            break
        fi
        if grep -q "^$item_number - " $MENU_FILE; then
            read -p "Enter quantity: " quantity
            item_price=$(grep "^$item_number - " $MENU_FILE | awk -F ' - ' '{print $4}')
            item_name=$(grep "^$item_number - " $MENU_FILE | awk -F ' - ' '{print $2}')
            item_desc=$(grep "^$item_number - " $MENU_FILE | awk -F ' - ' '{print $3}')
            total_item_price=$((item_price * quantity))
            total_price=$((total_price + total_item_price))
            order_items[$item_number]="$item_name - $item_desc - $quantity - $total_item_price"
        else
            echo
            echo "Invalid Item Number. Please try again."
        fi
    done

    if [ ${#order_items[@]} -eq 0 ]; then
        echo "No items ordered."
        read -p "Press any key to return to Customer Menu..." key
        customer_menu
        return
    fi
    
    order_id=$(date +%Y%m%d-%H%M%S)
    # order_id=$(date +%s)
    echo "Order ID: $order_id" >> $ORDERS_FILE
    echo "Customer Name: $customer_name" >> $ORDERS_FILE
    echo "Phone Number: $phone_number" >> $ORDERS_FILE
    echo "Items Ordered:" >> $ORDERS_FILE
    for item in "${!order_items[@]}"; do
        echo "$item - ${order_items[$item]}" >> $ORDERS_FILE
    done
    echo "Total Price: $total_price" >> $ORDERS_FILE
    echo "-----------------------------" >> $ORDERS_FILE

    echo "Order placed successfully. Your Order ID is $order_id. Please note it."

    echo "Total Price: $total_price"
    
    echo "Please pay the bill (type 'paid' to confirm payment):"
    read payment_status

    if [ "$payment_status" = "paid" ];then
        if [[ -f $CASH_FILE ]]; then
            current_cash=$(cat $CASH_FILE)
            new_cash=$((current_cash + total_price))
            echo $new_cash > $CASH_FILE
        else
            echo $total_price > $CASH_FILE
        fi
        echo "Payment confirmed."
    else 
        echo "Payment not confirmed. Deleting order."
        sed -i '$d' $ORDERS_FILE
    fi

    # if [[ -f $CASH_FILE ]]; then
    #     current_cash=$(cat $CASH_FILE)
    #     new_cash=$((current_cash + total_price))
    #     echo $new_cash > $CASH_FILE
    # else
    #     echo $total_price > $CASH_FILE
    # fi

    echo
    read -p "Press any key to return to Customer Menu..." key
    customer_menu
}

view_orders_customer() {
    clear
    echo "-----------------------------"
    echo "       Your Orders "
    echo "-----------------------------"
    echo
    
    read -p "Enter Customer Name to view orders: " customer_name
    read -p "Enter Order ID: " order_id
    
    if [ -z "$order_id" ]; then
        echo "Order ID not found."
        read -p "If you forgot Order ID, type 'forgot' to retrieve it or press any key to return to the menu: " option
        if [[ $option == "forgot" ]]; then
            read -p "Enter name: " forgot_name
            read -p "Enter Phone Number: " forgot_phone

            latest_order_id=$(grep -B 3 -e "Customer Name: $forgot_name" -e "Phone Number: $forgot_phone" $ORDERS_FILE | grep "Order ID:" | awk -F 'Order ID: ' '{print $2}' | tail -n 1)

            if [ -z "$latest_order_id" ]; then 
                echo "Order not found or was automatically deleted due to non-payment. Please place the order again. Thank you."
            else    
                echo "Your Order ID is $latest_order_id. Please use this ID to view your order details."
            fi
        else
            echo "Returning to menu."
        fi
    else
        if grep -q "Order ID: $order_id" $ORDERS_FILE; then
            echo "-----------------------------"
            sed -n "/Order ID: $order_id/,/^-----------------------------$/p" $ORDERS_FILE
        else
            echo "Order not found."
            read -p "If you forgot Order ID, type 'forgot' to retrieve it or press any key to return to the menu: " option
            if [[ $option == "forgot" ]]; then
                read -p "Enter name: " forgot_name
                read -p "Enter Phone Number: " forgot_phone

                latest_order_id=$(grep -B 3 -e "Customer Name: $forgot_name" -e "Phone Number: $forgot_phone" $ORDERS_FILE | grep "Order ID:" | awk -F 'Order ID: ' '{print $2}' | tail -n 1)

                if [ -z "$latest_order_id" ]; then 
                    echo "Order not found or was automatically deleted due to non-payment. Please place the order again. Thank you."
                else    
                    echo "Your Order ID is $latest_order_id. Please use this ID to view your order details."
                fi
            fi
        fi
    fi
    
    # sed -n '/Order ID:/,/^-----------------------------$/ {
    #     /Customer Name: '"$customer_name"'/,/^-----------------------------$/p
    # }' $ORDERS_FILE
    
    echo "-----------------------------"
    read -p "Press any key to return to Customer Menu..." key
    customer_menu
}

cancel_order() {
    clear
    echo "-----------------------------"
    echo "       Cancel Order "
    echo "-----------------------------"
    echo

    read -p "Enter Customer Name: " customer_name
    read -p "Enter Order ID: " order_id

    if [ -z "$order_id" ]; then
        echo "Order ID is required to cancel an order."
        echo "If you forgot your Order ID, please go to the 'View Orders' option to find it."
        read -p "Press any key to return to the Customer Menu..." key
        customer_menu
        return
    fi

    if grep -p "Order ID: $order_id" $ORDERS_FILE; then
        order_amount=$(sed -n "/Order ID: $order_id/,/^-----------------------------$/p" $ORDERS_FILE | grep -oP '(?<=Total Amount: )\d+')

        sed -i "/Order ID: $order_id/,/^-----------------------------$/d" $ORDERS_FILE

        if [ -n "$order_amount" ]; then
            current_cash=$(cat cash.txt)
            updated_cash=$((current_cash - order_amount))
            echo "$updated_cash" > cash.txt
        fi

        echo "Order with ID $order_id has been successfully canceled."
    else
        echo "Order ID not found. No action taken."
        echo "-----------------------------"
        echo "If you forgot your Order ID, please go to the 'View Orders' option to find it."
        read -p "Press any key to return to the Customer Menu..." key
        customer_menu
    fi
}

exit_screen() {
    clear
    echo "---------------------------------"
    echo " Thank you for using Restaurant Management System "
    echo "---------------------------------"
    exit 0
}

welcome_screen
