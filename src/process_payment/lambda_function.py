import json
import payment_service
import db_service


class InvalidPaymentDetails(Exception):
    pass


class PaymentServiceUnavailable(Exception):
    pass


class PaymentServiceError(Exception):
    pass


def update_order_details(order, payment):
    order["order_status"] = "payment_successful"
    order["order_status_reason"] = "Order payment transaction has been successful"
    order["transactions"] = [{
        "transaction_id": payment["txn_id"],
        "transaction_status": payment["txn_status"],
        "transaction_amount": payment["txn_amount"],
    }]
    return db_service.update_order(order)


def lambda_handler(event, context):
    payment = payment_service.send_request(event)
    
    status = payment["status"]
    message = payment["message"]
    
    if status == 400:
        raise InvalidPaymentDetails(message)
    
    if status == 503:
        raise PaymentServiceUnavailable(message)
    
    if status == 500:
        raise PaymentServiceError(message)
    
    if "order" in event:
        order = update_order_details(event["order"], payment)
    
        return {
            'order': order
        }
