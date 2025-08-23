import json
import os
import boto3
import pymysql

port = 3306
db_name = os.environ['DB_NAME']
db_user_name = os.environ['DB_USER']
db_password = os.environ['DB_PASSWORD']
db_host = os.environ['DB_HOST']
s3_frontend_bucket_url = os.environ['S3_FRONTEND_BUCKET_URL']

CORS_HEADERS = {
    "Access-Control-Allow-Origin": s3_frontend_bucket_url,
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "GET,POST,DELETE,OPTIONS"
}

def lambda_handler(event, context):
    try:
        connection = pymysql.connect(
            host=db_host,
            user=db_user_name,
            password=db_password,
            db=db_name,
            port=port
        )
        method = event.get("httpMethod", "GET")
        if method == "OPTIONS":
            return {
                "statusCode": 200,
                "headers": CORS_HEADERS,
                "body": ""
            }
        if method == "POST":
            body = event.get("body")
            if body:
                data = json.loads(body)
                dish_name = data.get("dish_name")
                price = data.get("price")
                description = data.get("description", "")
                available = data.get("available", True)
                with connection.cursor() as cursor:
                    cursor.execute(
                        "INSERT INTO menu (dish_name, price, description, available) VALUES (%s, %s, %s, %s)",
                        (dish_name, price, description, available)
                    )
                    connection.commit()
                return {
                    "statusCode": 201,
                    "headers": CORS_HEADERS,
                    "body": json.dumps({"message": "Plato agregado exitosamente"})
                }
            else:
                return {
                    "statusCode": 400,
                    "headers": CORS_HEADERS,
                    "body": json.dumps({"error": "Faltan datos en el body"})
                }
        elif method == "DELETE":
            body = event.get("body")
            if body:
                data = json.loads(body)
                menu_id = data.get("id")
                if menu_id is not None:
                    with connection.cursor() as cursor:
                        cursor.execute(
                            "DELETE FROM menu WHERE id = %s",
                            (menu_id,)
                        )
                        connection.commit()
                    return {
                        "statusCode": 200,
                        "headers": CORS_HEADERS,
                        "body": json.dumps({"message": f"Plato con id {menu_id} eliminado exitosamente"})
                    }
                else:
                    return {
                        "statusCode": 400,
                        "headers": CORS_HEADERS,
                        "body": json.dumps({"error": "Falta el id en el body"})
                    }
            else:
                return {
                    "statusCode": 400,
                    "headers": CORS_HEADERS,
                    "body": json.dumps({"error": "Faltan datos en el body"})
                }
        else:
            with connection.cursor() as cursor:
                cursor.execute('SELECT id, dish_name FROM menu;')
                result = cursor.fetchall()
                # result is a list of tuples (id, dish_name)
                items = [{"id": row[0], "dish_name": row[1]} for row in result]
            return {
                "statusCode": 200,
                "headers": CORS_HEADERS,
                "body": json.dumps(items)
            }
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }
    
