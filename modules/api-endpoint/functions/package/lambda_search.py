"""
this lambda function will search library for given string
"""

import json
import boto3
from boto3.dynamodb.conditions import Key, Attr
import logging
import os
import error_response

region = os.environ['AWS_REGION']
db_table = os.environ['TABLE_NAME']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

logger.info('### ENVIRONMENT VARIABLES ###')
logger.info("AWS region: {}".format(region))
logger.info("dynamodb table: {}".format(db_table))


def get_response(message):
    """ scan dynamodb and return results
  
    Parameters
    ----------
    message: str
          search string
  
    Returns:
    --------
    response: json
              json formatted response
    """  
    message = message.lower()
    dynamodb = boto3.resource('dynamodb', region_name=region)
    table = dynamodb.Table(db_table)

    ## scan dynamodb for results 
    try:
      response = table.scan(FilterExpression=Attr('search_title').contains(str(message)) | Attr('search_artist').contains(str(message)), ProjectionExpression = "artist, mlevel, rating, released, difficulty, title")
      data = response['Items']

      logger.info('### Dynamodb Results ###')
      logger.info(data)

      jsonString = json.dumps(data, default=str)

      response = {
          "statusCode": 200,
          "body": jsonString,
      }
      
    except Exception as e:
      e = json.dumps(e, default=str)
      response = {
          "statusCode": 400,
          "body": e,
      }

    return response

def lambda_handler(event, context):
  try:
    message = event['queryStringParameters']['message']
    logger.info("Message: {}".format(message))
    return get_response(message)
  except Exception as e:
    logger.info("Error: {}".format(e))
    return error_response.response(e)


    
    