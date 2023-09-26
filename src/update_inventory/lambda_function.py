import json
import inventory_service
import db_service


class InventoryServiceUnavailable(Exception):
    pass


class InventoryServiceError(Exception):
    pass


def update_order_details(order, inventory):
    order["order_status"] = "inventory_stock_updated"
    order["order_status_reason"] = "Inventory stock update has been successful"

    return db_service.update_order(order)
    

def lambda_handler(event, context):
    response = inventory_service.send_request(event)
    
    status = response["status"]
    message = response["message"]
    
    if status == 503:
        raise InventoryServiceUnavailable(message)
    
    if status == 500:
        raise InventoryServiceError(message)
    
    order = update_order_details(event["order"], response)
    return {
        'order': order
    }
