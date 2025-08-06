import json
import os
import boto3
import pymysql

# RDS settings
port = 3306
db_name = os.environ['DB_NAME']
db_user_name = os.environ['DB_USER']
db_password = os.environ['DB_PASSWORD']
db_host = os.environ['DB_HOST']

def lambda_handler(event, context):
    try:
        connection = pymysql.connect(
            host=db_host,
            user=db_user_name,
            password=db_password,
            db="sushi",
            port=port
        )
        
        with connection.cursor() as cursor:
            cursor.execute('SELECT nombre_plato FROM menu_sushi;')
            result = cursor.fetchone()

        return result
        
    except Exception as e:
        return (f"Error: {str(e)}")  # Return an error message if an exception occurs 
    
