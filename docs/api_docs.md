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
- 401 Unauthorized
- 404 Not Found – Transaction ID does not exist
