package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	_ "github.com/go-sql-driver/mysql"
)

var corsHeaders = map[string]string{
	"Access-Control-Allow-Origin":  os.Getenv("S3_FRONTEND_BUCKET_URL"),
	"Access-Control-Allow-Headers": "Content-Type",
	"Access-Control-Allow-Methods": "GET,POST,DELETE,OPTIONS",
}

type Order struct {
	ID            int64   `json:"id,omitempty"`
	NombreCliente string  `json:"nombre_cliente"`
	Direccion     string  `json:"direccion"`
	Telefono      string  `json:"telefono"`
	Items         []int64 `json:"items"`
	Total         float64 `json:"total"`
}

func getDB() (*sql.DB, error) {
	dbUser := os.Getenv("DB_USER")
	dbPass := os.Getenv("DB_PASSWORD")
	dbHost := os.Getenv("DB_HOST")
	dbName := os.Getenv("DB_NAME")
	dsn := fmt.Sprintf("%s:%s@tcp(%s:3306)/%s?parseTime=true", dbUser, dbPass, dbHost, dbName)
	return sql.Open("mysql", dsn)
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	method := request.HTTPMethod
	switch method {
	case "OPTIONS":
		return events.APIGatewayProxyResponse{
			StatusCode: 200,
			Headers:    corsHeaders,
			Body:       "",
		}, nil
	case "POST":
		var order Order
		if err := json.Unmarshal([]byte(request.Body), &order); err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: 400,
				Headers:    corsHeaders,
				Body:       `{"error": "Body inválido"}`,
			}, nil
		}
		db, err := getDB()
		if err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: 500,
				Headers:    corsHeaders,
				Body:       `{"error": "No se pudo conectar a la base de datos"}`,
			}, nil
		}
		defer db.Close()
		tx, err := db.Begin()
		if err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: 500,
				Headers:    corsHeaders,
				Body:       `{"error": "No se pudo iniciar la transacción"}`,
			}, nil
		}
		res, err := tx.Exec("INSERT INTO ordenes (nombre_cliente, direccion, telefono, total) VALUES (?, ?, ?, ?)", order.NombreCliente, order.Direccion, order.Telefono, order.Total)
		if err != nil {
			tx.Rollback()
			return events.APIGatewayProxyResponse{
				StatusCode: 500,
				Headers:    corsHeaders,
				Body:       `{"error": "No se pudo guardar la orden"}`,
			}, nil
		}
		ordenID, err := res.LastInsertId()
		if err != nil {
			tx.Rollback()
			return events.APIGatewayProxyResponse{
				StatusCode: 500,
				Headers:    corsHeaders,
				Body:       `{"error": "No se pudo obtener el ID de la orden"}`,
			}, nil
		}
		for _, itemID := range order.Items {
			_, err := tx.Exec("INSERT INTO orden_items (orden_id, menu_id) VALUES (?, ?)", ordenID, itemID)
			if err != nil {
				tx.Rollback()
				return events.APIGatewayProxyResponse{
					StatusCode: 500,
					Headers:    corsHeaders,
					Body:       `{"error": "No se pudieron guardar los items"}`,
				}, nil
			}
		}
		if err := tx.Commit(); err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: 500,
				Headers:    corsHeaders,
				Body:       `{"error": "No se pudo guardar la orden (commit)"}`,
			}, nil
		}
		return events.APIGatewayProxyResponse{
			StatusCode: 201,
			Headers:    corsHeaders,
			Body:       fmt.Sprintf(`{"message": "Orden recibida correctamente", "orden_id": %d}`, ordenID),
		}, nil
	case "DELETE":
		var req struct {
			OrdenID int64 `json:"orden_id"`
		}
		if err := json.Unmarshal([]byte(request.Body), &req); err != nil || req.OrdenID == 0 {
			return events.APIGatewayProxyResponse{
				StatusCode: 400,
				Headers:    corsHeaders,
				Body:       `{"error": "Body inválido o falta orden_id"}`,
			}, nil
		}
		db, err := getDB()
		if err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: 500,
				Headers:    corsHeaders,
				Body:       `{"error": "No se pudo conectar a la base de datos"}`,
			}, nil
		}
		defer db.Close()
		tx, err := db.Begin()
		if err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: 500,
				Headers:    corsHeaders,
				Body:       `{"error": "No se pudo iniciar la transacción"}`,
			}, nil
		}
		_, err = tx.Exec("DELETE FROM orden_items WHERE orden_id = ?", req.OrdenID)
		if err != nil {
			tx.Rollback()
			return events.APIGatewayProxyResponse{
				StatusCode: 500,
				Headers:    corsHeaders,
				Body:       `{"error": "No se pudieron eliminar los items"}`,
			}, nil
		}
		_, err = tx.Exec("DELETE FROM ordenes WHERE id = ?", req.OrdenID)
		if err != nil {
			tx.Rollback()
			return events.APIGatewayProxyResponse{
				StatusCode: 500,
				Headers:    corsHeaders,
				Body:       `{"error": "No se pudo eliminar la orden"}`,
			}, nil
		}
		if err := tx.Commit(); err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: 500,
				Headers:    corsHeaders,
				Body:       `{"error": "No se pudo eliminar la orden (commit)"}`,
			}, nil
		}
		return events.APIGatewayProxyResponse{
			StatusCode: 200,
			Headers:    corsHeaders,
			Body:       fmt.Sprintf(`{"message": "Orden %d eliminada correctamente"}`, req.OrdenID),
		}, nil
	case "GET":
		db, err := getDB()
		if err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: 500,
				Headers:    corsHeaders,
				Body:       `{"error": "No se pudo conectar a la base de datos"}`,
			}, nil
		}
		defer db.Close()
		rows, err := db.Query("SELECT id, nombre_cliente, direccion, telefono, total FROM ordenes")
		if err != nil {
			return events.APIGatewayProxyResponse{
				StatusCode: 500,
				Headers:    corsHeaders,
				Body:       `{"error": "No se pudieron obtener las órdenes"}`,
			}, nil
		}
		defer rows.Close()
		var ordenes []Order
		for rows.Next() {
			var o Order
			if err := rows.Scan(&o.ID, &o.NombreCliente, &o.Direccion, &o.Telefono, &o.Total); err != nil {
				continue
			}
			itemRows, err := db.Query("SELECT menu_id FROM orden_items WHERE orden_id = ?", o.ID)
			if err == nil {
				for itemRows.Next() {
					var itemID int64
					if err := itemRows.Scan(&itemID); err == nil {
						o.Items = append(o.Items, itemID)
					}
				}
				itemRows.Close()
			}
			ordenes = append(ordenes, o)
		}
		resp, _ := json.Marshal(ordenes)
		return events.APIGatewayProxyResponse{
			StatusCode: 200,
			Headers:    corsHeaders,
			Body:       string(resp),
		}, nil
	}
	// Si llega aquí, es un método no soportado
	return events.APIGatewayProxyResponse{
		StatusCode: 405,
		Headers:    corsHeaders,
		Body:       `{"error": "Método no permitido"}`,
	}, nil
}

func main() {
	lambda.Start(handler)
}
