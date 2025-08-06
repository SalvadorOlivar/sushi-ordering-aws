## Proyecto: Sistema de pedidos de sushi automatizado en AWS

### Descripción general
Este proyecto permite a los usuarios realizar pedidos de sushi de forma fácil y rápida desde una página web interactiva. Los pedidos se procesan automáticamente y el restaurante recibe notificaciones instantáneas.

### Arquitectura de la solución

**Frontend:**
- Aplicación web interactiva (puede ser una SPA con React, Vue, o una web sencilla con HTML/JS).
- El frontend se despliega como sitio estático en S3 y se accede mediante CloudFront (ambos tienen capa gratuita).
- El frontend envía los pedidos a una API Gateway.

**Backend e integración AWS:**
- **API Gateway:** Recibe las solicitudes de pedidos desde el frontend.
- **SQS:** Cola para almacenar los pedidos recibidos.
- **Lambda:** Función que se activa con los mensajes de SQS, procesa el pedido y lo guarda en RDS.
- **RDS (MySQL/PostgreSQL):** Base de datos para almacenar los pedidos.
- **SNS:** Notifica al restaurante (email/SMS) cuando hay un nuevo pedido.

### Diagrama de flujo

Frontend (S3/CloudFront) → API Gateway → SQS → Lambda → RDS
                                              ↘
                                               SNS (notificación)

### Terraform
Toda la infraestructura se define y despliega con Terraform, incluyendo:
- S3 y CloudFront para el frontend
- API Gateway
- SQS
- Lambda
- RDS
- SNS

### Ventajas
- 100% capa gratuita de AWS
- Escalable y fácil de mantener
- Experiencia de usuario interactiva

