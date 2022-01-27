"""
this lambda function will get rating for a specific song
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


def rating_cal(rating_list):
    """ this method will calculate highest, lowest and average rating

    Parameters
    ----------
    rating_list: list,
          list with all the ratings

    Returns:
    --------
    highest: int
            max rating
    lowest: int
            lowest rating
    avg: float
            avg rating
    """

    highest = 0
    lowest = 0
    avg = 0

    if len(rating_list) > 0:
        rating_list = list(map(int, rating_list))
        highest = max(rating_list)
        lowest = min(rating_list)
        avg = sum(rating_list) / len(rating_list)

    logger.info("max: {}, min: {}, avg: {}".format(highest, lowest, avg))
    return highest, lowest, avg


def get_response(id):
    """ scan dynamodb and return results

    Parameters
    ----------
    id: int
          id of a song

    Returns:
    --------
    response: json
              json formatted response
    """
    dynamodb = boto3.resource('dynamodb', region_name=region)
    table = dynamodb.Table(db_table)

    try:
        response = table.scan(FilterExpression=Attr(
            'id').eq(id), ProjectionExpression="rating")
        data = response['Items'][0]['rating']
        logger.info('### Dynamodb Results ###')
        logger.info(data)

        if len(data) > 0:
            results = {
                'id': id,
                'highest': rating_cal(data)[0],
                'lowest': rating_cal(data)[1],
                'average':  rating_cal(data)[2]
            }

            results = json.dumps(results, default=str)

            response = {
                'statusCode': 200,
                'body': results
            }
        else:
            response = {
                'statusCode': 400,
                'body': "No ratings found for given id"
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
        id = event['queryStringParameters']['id']
        id = int(id)
        logger.info("id: {}".format(id))
        return get_response(id)
    except Exception as e:
        logger.info("Error: {}".format(e))
        return error_response.response(e)
