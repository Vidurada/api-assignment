"""
this lambda function will return average difficulty of the songs in the library
"""

import json
import boto3
from boto3.dynamodb.conditions import Attr
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

def get_response(level):
	""" scan dynamodb and return results
    
    Parameters
    ----------
    level: str, optional
        level of the song
  
    Returns:
    --------
    response: json
            formated response from the dynamodb 
    
	"""
	
	dynamodb = boto3.resource('dynamodb', region_name=region)
	table = dynamodb.Table(db_table)

	try:
		if level is not None:
			level = int(level)
			diff = table.scan(FilterExpression=Attr('mlevel').eq(level), ProjectionExpression = "difficulty")
		else:
			diff = table.scan(ProjectionExpression = "difficulty")
			
		data = diff['Items']
		logger.info('### Dynamodb Results ###')
		logger.info(data)
		
		total = 0
		items = len(data)
		if items > 0:
			for i in data:
				total = total + float(i['difficulty'])
				avg_diff = total/items
		else:
			avg_diff = 0

		if level is None:
			results = {
            "level": 'all',
            "average": str(avg_diff)
        }
		  
		else:
			results = {
            "level": level,
            "average": str(avg_diff)
          	}
			  
		response = {
          "statusCode": 200,
          "body": json.dumps(results, default=str),
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
      # check if level parameter is given. if not set level = None
      try:
        level = event['queryStringParameters']['level']
      except:
        level = None
      logger.info("level: {}".format(level))
      return get_response(level)
    except Exception as e:
      logger.info("Error: {}".format(e))
      return error_response.response(e)
         