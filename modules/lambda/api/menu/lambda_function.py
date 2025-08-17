import json
import os
import boto3
import pymysql

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "http://sushi-frontend-static-website-65a11ec9.s3-website-us-east-1.amazonaws.com",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "GET,POST,DELETE,OPTIONS"
}

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
                nombre_plato = data.get("nombre_plato")
                precio = data.get("precio")
                descripcion = data.get("descripcion", "")
                disponible = data.get("disponible", True)
                with connection.cursor() as cursor:
                    cursor.execute(
                        "INSERT INTO menu_sushi (nombre_plato, precio, descripcion, disponible) VALUES (%s, %s, %s, %s)",
                        (nombre_plato, precio, descripcion, disponible)
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
                            "DELETE FROM menu_sushi WHERE id = %s",
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
                cursor.execute('SELECT id, nombre_plato FROM menu_sushi;')
                result = cursor.fetchall()
                # result es una lista de tuplas (id, nombre_plato)
                items = [{"id": row[0], "nombre_plato": row[1]} for row in result]
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
    
