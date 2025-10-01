#  MoMo SMS Transactions API Documentation

This REST API provides secure access to mobile money SMS transaction records. All endpoints require Basic Authentication.

---

## Authentication

- **Method**: Basic Auth  
- **Header**:  
  `Authorization: Basic <base64(username:password)>`  
- **Example**:  
  `Authorization: Basic YWRtaW46cGFzczEyMw==` (admin:pass123)

---

##  Endpoints Overview

| Method | Endpoint                  | Description                        |
|--------|---------------------------|------------------------------------|
| GET    | `/transactions`           | List all transactions              |
| GET    | `/transactions/{id}`      | Retrieve a specific transaction    |
| POST   | `/transactions`           | Create a new transaction           |
| PUT    | `/transactions/{id}`      | Update an existing transaction     |
| DELETE | `/transactions/{id}`      | Delete a transaction               |

---

##  GET /transactions

**Description**: Returns a list of all SMS transactions.

**Request Example**:
```http
GET /transactions
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
GET /transactions/{id}

Retrieve a specific transaction.

Request Example
curl -u admin:password http://localhost:8000/transactions/1
Response Example:
{
  "id": "1",
  "type": "send",
  "amount": "2500",
  "sender": "+250781234567",
  "receiver": "+250788765432",
  "timestamp": "2025-09-01T10:15:00",
  "body": "Sent 2500 RWF to +250788765432"
}
Error Codes

401 Unauthorized

404 Not Found
POST /transactions

Create a new transaction.

Request Example:
curl -u admin:password -X POST http://localhost:8000/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "id": "6",
    "type": "deposit",
    "amount": "1000",
    "sender": "BankAgent003",
    "receiver": "+250781234567",
    "timestamp": "2025-09-10T15:00:00",
    "body": "Deposited 1000 RWF"
  }'
Response Example:
{"message": "Transaction added successfully"}
Error Codes

400 Bad Request

401 Unauthorized

409 Conflict

PUT /transactions/{id}

Update an existing transaction.

Request Example:
curl -u admin:password -X PUT http://localhost:8000/transactions/6 \
  -H "Content-Type: application/json" \
  -d '{
    "type": "withdraw",
    "amount": "800"
  }'
Response Example:
{"message": "Transaction updated successfully"}
Error Codes

400 Bad Request

401 Unauthorized

404 Not Found

DELETE /transactions/{id}

Delete a transaction.

Request Example:
curl -u admin:password -X DELETE http://localhost:8000/transactions/6
Response Example:
{"message": "Transaction deleted successfully"}
Error Codes

401 Unauthorized

404 Not Found
