# 📘 MoMo SMS Transactions API Documentation

This REST API provides secure access to mobile money SMS transaction records. All endpoints require Basic Authentication.

---

## 🔐 Authentication

- **Method**: Basic Auth  
- **Header**:  
  `Authorization: Basic <base64(username:password)>`  
- **Example**:  
  `Authorization: Basic YWRtaW46cGFzczEyMw==` (admin:pass123)

---

## 📂 Endpoints Overview

| Method | Endpoint                  | Description                        |
|--------|---------------------------|------------------------------------|
| GET    | `/transactions`           | List all transactions              |
| GET    | `/transactions/{id}`      | Retrieve a specific transaction    |
| POST   | `/transactions`           | Create a new transaction           |
| PUT    | `/transactions/{id}`      | Update an existing transaction     |
| DELETE | `/transactions/{id}`      | Delete a transaction               |

---

## GET /transactions/{id}
Description: Returns a single transaction by ID.
Request Example:
GET /transactions/5
Authorization: Basic YWRtaW46cGFzczEyMw==
Response Example:
{
  "id": 5,
  "type": "send",
  "amount": "2500",
  "sender": "0788123456",
  "receiver": "0788999888",
  "timestamp": "2023-08-02T09:15:00"
}
Error Codes:
- 401 Unauthorized
- 404 Not Found – Transaction ID does not exist

## POST /transactions
Description: Creates a new transaction.
Request Example:
POST /transactions
Authorization: Basic YWRtaW46cGFzczEyMw==
Content-Type: application/json

{
  "type": "withdraw",
  "amount": "1000",
  "sender": "0788123456",
  "receiver": "Agent001",
  "timestamp": "2023-08-03T11:00:00"
}

Response Example:
{
  "message": "Transaction created",
  "id": 21
}
Error Codes:
- 400 Bad Request – Missing or invalid fields
- 401 Unauthorized



## PUT /transactions/{id}
Description: Updates an existing transaction.
Request Example:
PUT /transactions/3
Authorization: Basic YWRtaW46cGFzczEyMw==
Content-Type: application/json

{
  "type": "send",
  "amount": "3000",
  "sender": "0788123456",
  "receiver": "0788111222",
  "timestamp": "2023-08-04T10:00:00"
}
Response Example:
{
  "message": "Transaction updated"
}

Error Codes:
- 400 Bad Request
- 401 Unauthorized
- 404 Not Found


## DELETE /transactions/{id}
**Description**: Deletes a transaction by ID.
**Request Example**:
```http
DELETE /transactions/2
Authorization: Basic YWRtaW46cGFzczEyMw==

Response Example:
{
  "message": "Transaction deleted"
}
```
Error Codes:
- 401 Unauthorized
- 404 Not Found


##  GET /transactions

**Description**: Returns a list of all SMS transactions.

**Request Example**:
```http
GET /transactions
Authorization: Basic YWRtaW46cGFzczEyMw==
