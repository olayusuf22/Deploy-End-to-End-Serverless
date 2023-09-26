import json
import db_service


def update_order_details(order):
    # Call notification service providing the order details
    #comms_service.notify_customer(order)

    order["order_status"] = "order_initial_comms_sent"
    order["order_status_reason"] = "Order initial notification sent to customer"

    return db_service.update_order(order)


def lambda_handler(event, context):
    for record in event['Records']:
        payload = record['body']
        payload = json.loads(payload)
        
        message = payload["Message"]
        message = json.loads(message)
        
        order = message["order"]
        
        update_order_details(order)
        print(f"Handled communication for order: {order['order_id']}")
