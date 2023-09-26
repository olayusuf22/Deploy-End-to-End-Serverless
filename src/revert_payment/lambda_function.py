import json
import payment_service
import db_service


def update_order_details(order, transaction):
    order["order_status"] = "payment_refunded_stock_update_failed"
    order["order_status_reason"] = "Order payment has been refunded successfully"
    txns = order["transactions"]
    txns.append({
        "transaction_id": transaction["txn_id"],
        "transaction_status": transaction["txn_status"],
        "transaction_amount": transaction["txn_amount"],
    })
    return db_service.update_order(order)


def lambda_handler(event, context):
    response = payment_service.refund_payment(event)
    
    order = update_order_details(event["order"], response)
    return {
        'order': order
    }
