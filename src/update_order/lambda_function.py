import json
import db_service


def update_order_details(order, error):
    order["order_status"] = "order_failed"
    order["order_status_reason"] = error["Error"]
    
    return db_service.update_order(order)
    

def lambda_handler(event, context):
    if "order" in event and "error" in event:
        order = update_order_details(event["order"], event["error"])
    
    return {
        "order": order
    }
