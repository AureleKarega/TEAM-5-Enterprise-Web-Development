### GET /transactions
- Returns all transactions
- Requires Basic Auth

**Request:**
GET /transactions
Authorization: Basic YWRtaW46cGFzczEyMw==

**Response:**
200 OK
[
  {
    "id": 0,
    "type": "deposit",
    "amount": "5000",
    ...
  }
]

**Errors:**
401 Unauthorized
404 Not Found
