import json
import db_service


def lambda_handler(event, context):
    order = db_service.create_order(event)
    return {
        'order': order
    }
