# API Reference

## Base URL

```
http://localhost:3000
```

All API routes are prefixed with `/api`. The server is a Fastify application running on the port defined by the `PORT` environment variable (default `3000`).

## Authentication

SKY Companion uses JWT bearer tokens for authentication. After registering or logging in, the server returns a `token` field. Include this token in the `Authorization` header of all authenticated requests:

```
Authorization: Bearer <token>
```

The JWT payload contains `{ id, email }` and is signed with the `JWT_SECRET` environment variable. There is no token expiration configured in the current implementation.

Endpoints marked with **Auth: JWT** will return a `401` error if the token is missing or invalid.

---

## Auth Routes

### POST /api/auth/register

Create a new user account.

**Auth:** None

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | User email address (must be unique) |
| `password` | string | Yes | Password (hashed with bcrypt, cost factor 10) |
| `courseCode` | string | Yes | AoL SKY course code (e.g. `SKY-2026`) |

**Success Response (200):**

```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "course_code": "SKY-2026",
    "is_verified": false
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Error Responses:**

| Status | Body | Condition |
|--------|------|-----------|
| 400 | `{ "error": "User already exists" }` | Email is already registered |

---

### POST /api/auth/login

Authenticate an existing user.

**Auth:** None

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Registered email address |
| `password` | string | Yes | Account password |

**Success Response (200):**

```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "is_verified": true,
    "current_streak": 12,
    "total_xp": 1400,
    "level": 2
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Error Responses:**

| Status | Body | Condition |
|--------|------|-----------|
| 401 | `{ "error": "Invalid credentials" }` | Email not found or password mismatch |

---

### GET /api/auth/me

Get the current authenticated user's profile.

**Auth:** JWT

**Success Response (200):**

```json
{
  "id": 1,
  "email": "user@example.com",
  "is_verified": true,
  "current_streak": 12,
  "max_streak": 15,
  "total_xp": 1400,
  "level": 2
}
```

**Error Responses:**

| Status | Body | Condition |
|--------|------|-----------|
| 404 | `{ "error": "User not found" }` | JWT references a deleted user |

---

### POST /api/auth/verify-course

Verify a user's AoL course code. Currently accepts only the hard-coded code `SKY-2026`.

**Auth:** JWT

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `code` | string | Yes | Course code to verify |

**Success Response (200):**

```json
{
  "success": true
}
```

**Error Responses:**

| Status | Body | Condition |
|--------|------|-----------|
| 400 | `{ "error": "Invalid course code" }` | Code does not match `SKY-2026` |

---

## Session Routes

### POST /api/sessions/log

Log a completed practice session. This endpoint also triggers streak calculation, XP awards, level recalculation, and milestone bonuses server-side.

**Auth:** JWT

**Request Body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | Session type: `"full"` or `"short"` |
| `durationSeconds` | integer | Yes | Total session duration in seconds |
| `moodScore` | integer | No | Post-session mood (1-5 scale) |
| `hrvDelta` | integer | No | HRV change (reserved for Phase 2) |

**Success Response (200):**

```json
{
  "success": true,
  "session": {
    "id": 42,
    "user_id": 1,
    "type": "full",
    "duration_seconds": 1860,
    "completed_at": "2026-04-16T07:30:00.000Z",
    "hrv_delta": null,
    "mood_score": 4
  }
}
```

**Server-side effects:**

1. Inserts a row into `sessions` table
2. Inserts today's date into `streaks` table (idempotent per day)
3. Updates `current_streak`: increments if practiced yesterday, resets to 1 otherwise
4. Updates `max_streak` to the greater of current value and new streak
5. Awards +100 XP (hard-coded in the streak update query)
6. Awards +200 XP bonus if `current_streak` reaches exactly 7
7. Awards +500 XP bonus if `current_streak` reaches exactly 30
8. Awards +10 XP if `moodScore` is between 1 and 5
9. Recalculates `level` using non-linear XP thresholds

---

### GET /api/sessions/history

Get the authenticated user's recent session history.

**Auth:** JWT

**Success Response (200):**

```json
[
  {
    "id": 42,
    "user_id": 1,
    "type": "full",
    "duration_seconds": 1860,
    "completed_at": "2026-04-16T07:30:00.000Z",
    "hrv_delta": null,
    "mood_score": 4
  }
]
```

Returns the last 50 sessions ordered by `completed_at` descending.

---

### GET /api/sessions/streak-calendar

Get dates the user practiced within the last 70 days.

**Auth:** JWT

**Success Response (200):**

```json
{
  "dates": [
    "2026-04-16",
    "2026-04-15",
    "2026-04-14"
  ]
}
```

Returns ISO date strings (`YYYY-MM-DD`) ordered descending.

---

### GET /api/sessions/mood-trend

Get the user's mood scores from their last 14 sessions that include a mood rating.

**Auth:** JWT

**Success Response (200):**

```json
[
  { "day": 1, "mood": 3 },
  { "day": 2, "mood": 4 },
  { "day": 3, "mood": 5 }
]
```

Returns up to 14 entries ordered chronologically (oldest first). The `day` field is a sequential index starting at 1, not a calendar date.

---

## Health Check

### GET /health

**Auth:** None

**Success Response (200):**

```json
{
  "status": "ok",
  "timestamp": "2026-04-16T12:00:00.000Z"
}
```
