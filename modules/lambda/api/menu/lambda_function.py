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
            db=db_name,
            port=port
        )
        method = event.get("httpMethod", "GET")
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
                    "body": json.dumps({"message": "Plato agregado exitosamente"})
                }
            else:
                return {
                    "statusCode": 400,
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
                        "body": json.dumps({"message": f"Plato con id {menu_id} eliminado exitosamente"})
                    }
                else:
                    return {
                        "statusCode": 400,
                        "body": json.dumps({"error": "Falta el id en el body"})
                    }
            else:
                return {
                    "statusCode": 400,
                    "body": json.dumps({"error": "Faltan datos en el body"})
                }
        else:
            with connection.cursor() as cursor:
                cursor.execute('SELECT nombre_plato FROM menu_sushi;')
                result = cursor.fetchall()
                nombres = [row[0] for row in result]
            return {
                "statusCode": 200,
                "body": json.dumps(nombres)
            }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
    
