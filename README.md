
## Project: Automated Sushi Ordering System on AWS

### Overview
This project allows users to easily and quickly place sushi orders from an interactive web page. Orders are processed automatically and the restaurant receives instant notifications.

### Solution Architecture

**Frontend:**
- Interactive web application (can be a SPA with React, Vue, or a simple HTML/JS site).
- The frontend is deployed as a static site on S3 and accessed via CloudFront (both have a free tier).
- The frontend sends orders to an API Gateway.

**Backend and AWS Integration:**
- **API Gateway:** Receives order requests from the frontend.
- **SQS:** Queue to store received orders.
- **Lambda:** Function triggered by SQS messages, processes the order, and saves it in RDS.
- **RDS (MySQL/PostgreSQL):** Database to store orders.
- **SNS:** Notifies the restaurant (email/SMS) when there is a new order.

### Flow Diagram

<img width="1181" height="682" alt="sushi-serverless" src="https://github.com/user-attachments/assets/8de81a25-e4a0-422a-bd38-279e487f25dd" />


### Terraform
All infrastructure is defined and deployed with Terraform, including:
- S3 and CloudFront for the frontend
- API Gateway
- SQS
- Lambda
- RDS
- SNS

### Advantages
- 100% AWS free tier
- Scalable and easy to maintain
- Interactive user experience

