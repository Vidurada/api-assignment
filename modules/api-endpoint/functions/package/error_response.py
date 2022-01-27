import json

def response(e):
  """ return json with exception error message
  
  Parameters
  ----------
  e: str
        error message

  Returns:
  --------
  response: json
          formated json with error message
  
  """
  e = json.dumps(e, default=str)
  response = {
          "statusCode": 400,
          "body": e,
  }
  return response