"""
this lambda function will return all the songs in the library
"""


import json
import boto3
from decimal import Decimal
import os
import error_response
import logging

region = os.environ['AWS_REGION']
db_table = os.environ['TABLE_NAME']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

logger.info('### ENVIRONMENT VARIABLES ###')
logger.info("AWS region: {}".format(region))
logger.info("dynamodb table: {}".format(db_table))

def get_response(limit):
    """ scan dynamodb and return results
  
    Parameters
    ----------
    limit: str, optional
          pagination function. you can specify how many results to return

    Returns:
    --------
    response: json
            formated response from the dynamodb 
    
    """
    dynamodb = boto3.resource('dynamodb', region_name=region)
    table = dynamodb.Table(db_table)
    
    try:
        if limit is None:
             response = table.scan(ProjectionExpression = "id, artist, mlevel, rating, released, difficulty, title")
        else:
            limit = int(limit)
            response = table.scan(Limit=limit, ProjectionExpression = "id, artist, mlevel, rating, released, difficulty, title")

        data = response['Items']
        logger.info('### Dynamodb Results ###')
        logger.info(data)
        jsonString = json.dumps(data, default=str)

        responsess = {
            "statusCode": 200,
            "body": jsonString,
        }

    except Exception as e:
        e = json.dumps(e, default=str)
        response = {
          "statusCode": 400,
          "body": e,
        }

    return responsess

def lambda_handler(event, context):
    try:
        # check if limit parameter is given. if not set limit = None
        try:
            limit = event['queryStringParameters']['limit']
        except:
            limit = None
        logger.info("Limit: {}".format(limit))
        return get_response(limit)
    except Exception as e:
        logger.info("Error: {}".format(e))
        return error_response.response(e)
    
