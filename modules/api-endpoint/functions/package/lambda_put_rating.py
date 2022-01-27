"""
this lambda function will add a rating for a specific song
"""

import json
import boto3
from boto3.dynamodb.conditions import Key, Attr
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

def get_response(id, rating):
    """ scan dynamodb and return results
  
    Parameters
    ----------
    id: int, 
          id of the song
    rating: int, 
          rating for the song. value between 1 and 5

    Returns:
    --------
    response: json
            json formatted response
    """
    dynamodb = boto3.resource('dynamodb', region_name=region)
    table = dynamodb.Table(db_table)
    if rating > 0  and rating <=5:
        try:
            ##update
            response = table.update_item(
                Key={
                    'id': id
                },
                UpdateExpression="SET #l = list_append(#l, :vals)",
                ExpressionAttributeNames={
                    "#l":  'rating'
                },
                ExpressionAttributeValues={
                    ":vals":  [rating]
                }
            )

            response = {
                "statusCode": 200,
                "body": 'rating added',
            }

        except Exception as e:
          e = json.dumps(e, default=str)
          response = {
              "statusCode": 400,
              "body": e,
          }
    else:
        response = {
              "statusCode": 400,
              "body": "rating should be between 1 and 5",
          }


    return response
    

def lambda_handler(event, context):
    try:
        # get parameters from api request
        id = event['queryStringParameters']['id']
        id = int(id)
        rating = event['queryStringParameters']['rating']
        rating = int(rating)
        logger.info("id: {}".format(id))
        logger.info("rating: {}".format(rating))
        return get_response(id, rating)
    except Exception as e:
        logger.info("Error: {}".format(e))
        return error_response.response(e)
    