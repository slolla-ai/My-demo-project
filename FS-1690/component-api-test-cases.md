Test Type: Component API

Feature: Component API - Active Trailer Alerts Endpoint Behavior

Purpose:
Validate that the Active Trailer Alerts API endpoint handles requests, enforces parameter
constraints, and returns responses that conform to the documented contract examples.

Traceability: FS-1690 — AC1 (request/response examples), AC2 (parameters and constraints)

Base URLs:
active-trailer-alerts-api: resolved via environment configuration

Background:
Given the API service is operational
And required test data is available
And a trailer with ID "{TRAILER_ID}" exists in the system

[NEEDS CLARIFICATION: Replace {ALERT_ENDPOINT} with the actual path confirmed from the
OpenAPI spec — e.g. GET /trailers/{trailerId}/alerts or GET /alerts?trailerId=. See assumptions.md G1.]

---

Automation Recommendation: automatable

---

Scenario: Successful retrieval - active alerts returned for a valid trailer with active alerts
Given a valid authentication token with the required scope
And trailer "{TRAILER_ID}" has at least one active alert in the system
When active-trailer-alerts-api sends GET request to {ALERT_ENDPOINT} with trailer ID "{TRAILER_ID}"
Then the response status should be 200
And the response should conform to the API contract
And the response body should contain an array of alert objects
And each alert object should include all documented required fields
And each alert in the response should have status "ACTIVE"

Preconditions:
- Active Trailer Alerts API service is running and reachable
- A valid bearer token (or API key) with sufficient read scope is available
- At least one trailer with active alerts exists in the test dataset

Expected Results:
- HTTP 200 OK
- Response body is a JSON object or array matching the documented response example
- Each alert object contains the required fields documented in the API contract
  (field names and types must match the documented schema — see assumptions.md A3)
- No undocumented fields are present in the required response structure
- Response time is within acceptable SLA bounds

Assumptions: A1, A2, A3, A4, A5

---

Automation Recommendation: automatable

---

Scenario: Successful retrieval - empty result for trailer with no active alerts
Given a valid authentication token with the required scope
And trailer "{TRAILER_ID_NO_ALERTS}" has no active alerts in the system
When active-trailer-alerts-api sends GET request to {ALERT_ENDPOINT} with trailer ID "{TRAILER_ID_NO_ALERTS}"
Then the response status should be 200
And the response body should represent an empty alert collection
And the response should conform to the API contract

Preconditions:
- A valid bearer token with read scope is available
- A trailer exists in the system with zero active alerts

Expected Results:
- HTTP 200 OK
- Response body matches the documented empty-state example
  (e.g. empty array `[]` or `{ "alerts": [] }` as defined in the API contract)
- Response is not a 404 — the trailer exists, it simply has no active alerts

Assumptions: A1, A3, A4, A5

---

Automation Recommendation: automatable

---

Scenario: Authentication constraint - missing authentication token returns unauthorized
Given no authentication token is included in the request
When active-trailer-alerts-api sends GET request to {ALERT_ENDPOINT}
Then the response status should be 401
And the response should contain the expected error
And no alert data should be returned
And no unintended side effects should occur

Preconditions:
- No Authorization header or API key is provided in the request

Expected Results:
- HTTP 401 Unauthorized
- Response body contains a structured error matching the documented error format
  (e.g. `{ "error": "Unauthorized", "message": "..." }`)
- No alert data is included in the response body

Traceability: FS-1690 — AC2 (constraint: authentication is required)
Assumptions: A2

---

Automation Recommendation: automatable

---

Scenario: Authentication constraint - expired or invalid token returns unauthorized
Given an authentication token that is expired or structurally invalid
When active-trailer-alerts-api sends GET request to {ALERT_ENDPOINT} with the invalid token
Then the response status should be 401
And the response should contain the expected error
And no alert data should be returned
And no unintended side effects should occur

Preconditions:
- An expired or deliberately malformed token is provided in the Authorization header

Expected Results:
- HTTP 401 Unauthorized
- Response body contains a structured error matching the documented error format
- Token content is not reflected back in the response (no token echo)

Traceability: FS-1690 — AC2 (constraint: valid credentials required)
Assumptions: A2

---

Automation Recommendation: automatable

---

Scenario: Authorization constraint - valid token with insufficient permissions returns forbidden
Given a valid authentication token that lacks the scope required for alert retrieval
When active-trailer-alerts-api sends GET request to {ALERT_ENDPOINT} with trailer ID "{TRAILER_ID}"
Then the response status should be 403
And the response should contain the expected error
And no alert data should be returned
And no unintended side effects should occur

Preconditions:
- A valid token belonging to a user or service account without read-alerts permission is available

Expected Results:
- HTTP 403 Forbidden
- Response body contains a structured error matching the documented error format
- No partial alert data is included in the response

Traceability: FS-1690 — AC2 (constraint: authorization scope required)
Assumptions: A2

---

Automation Recommendation: automatable

---

Scenario: Parameter constraint - non-existent trailer ID returns not found
Given a valid authentication token with the required scope
And trailer ID "{TRAILER_ID_NONEXISTENT}" does not exist in the system
When active-trailer-alerts-api sends GET request to {ALERT_ENDPOINT} with trailer ID "{TRAILER_ID_NONEXISTENT}"
Then the response status should be 404
And the response should contain the expected error
And no unintended side effects should occur

Preconditions:
- A trailer ID is used that is correctly formatted but does not correspond to any record
- A valid bearer token is included

Expected Results:
- HTTP 404 Not Found
- Response body contains a structured error matching the documented error format
- Error message indicates the resource was not found (not a generic server error)

Traceability: FS-1690 — AC2 (constraint: trailer must exist)
Assumptions: A5

---

Automation Recommendation: automatable

---

Scenario: Response contract compliance - all required fields present with correct data types
Given a valid authentication token with the required scope
And trailer "{TRAILER_ID}" has at least one active alert
When active-trailer-alerts-api sends GET request to {ALERT_ENDPOINT} with trailer ID "{TRAILER_ID}"
Then the response status should be 200
And the response should conform to the API contract
And each alert object in the response should contain all required fields documented in the API contract
And all field values should be of the documented types
And no required field should be null unless the API contract explicitly permits it

Preconditions:
- A valid bearer token is available
- At least one active alert exists for the specified trailer

Expected Results:
- HTTP 200 OK
- Every alert object in the response body includes all required fields
- Field types match documented types (e.g. string IDs, ISO 8601 timestamps, numeric severity)
- No additional undocumented required fields are missing
- This scenario directly validates that the response matches the documented response example (AC1)

Traceability: FS-1690 — AC1 (response must match documented example)
Assumptions: A1, A3, A4

---

Automation Recommendation: automatable

---

Scenario Outline: Parameter constraint - invalid trailer ID formats are rejected
Given a valid authentication token with the required scope
When active-trailer-alerts-api sends GET request to {ALERT_ENDPOINT} with trailer ID "<invalid_id>"
Then the response status should be <expected_status>
And the response should contain the expected error

Examples:
| invalid_id            | expected_status | notes                                      |
| (empty string)        | 400             | path param present but empty               |
| @#$%                  | 400             | special characters                          |
| trailer-id-99999999   | 400 or 404      | [NEEDS CLARIFICATION: confirm format rule] |
| 0                     | 400 or 404      | zero/null-equivalent numeric ID            |
| a-very-long-string-exceeding-documented-max-length | 400 | exceeds max length constraint |

Preconditions:
- A valid bearer token is included in each request
- Test inputs are parameterized as shown in the Examples table

Expected Results (per row):
- HTTP 400 Bad Request for structurally invalid IDs (fails documented format constraint)
- HTTP 404 Not Found for correctly formatted IDs that reference no record
- No alert data is returned
- Error response conforms to the documented error format

Traceability: FS-1690 — AC2 (parameters and constraints must be documented and enforced)
Assumptions: A5
[NEEDS CLARIFICATION: Confirm the exact format rules for trailer ID to populate the Examples
table accurately. See assumptions.md G2.]
