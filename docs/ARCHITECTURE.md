# Architecture

## System Overview

SKY Companion is a 3-tier application:

```
┌─────────────────┐      HTTP/JSON      ┌─────────────────┐      SQL       ┌─────────────────┐
│  Expo Mobile App │  ←──────────────→  │   Fastify API    │  ←─────────→  │  PostgreSQL 15   │
│  (React Native)  │                    │   (Node.js)      │               │                  │
└─────────────────┘                     └────────┬─────────┘               └─────────────────┘
                                                 │
                                                 │  (registered, future use)
                                                 ▼
                                        ┌─────────────────┐
                                        │    Redis 7       │
                                        └─────────────────┘
```

Docker Compose (`docker-compose.yml`) provisions PostgreSQL and Redis. The mobile app runs via Expo Go during development.

---

## Mobile App Architecture

### Entry Point

`app/App.js` is the navigation root. It reads `isAuthenticated` and `hasOnboarded` from the Zustand store and conditionally renders one of three navigator trees:

1. **AuthStack** (not authenticated) -- `Login` and `Register` screens
2. **Onboarding** (authenticated, not onboarded) -- single `Onboarding` screen with internal step state
3. **Main** (authenticated and onboarded) -- bottom tab navigator with a stack overlay for `PostSession`

### Navigation Structure

| Navigator | Type | Screens |
|-----------|------|---------|
| AuthStack | Native Stack | Login, Register |
| Onboarding | Native Stack | Onboarding |
| MainTabs | Bottom Tab | Home, Practice, Progress, Community, Profile |
| Main | Native Stack | MainTabs, PostSession |

Tab icons use `lucide-react-native` (Home, Play, BarChart2, Users, User).

### State Management

State is managed with a single Zustand store at `app/src/store/useStore.js`.

**Store shape:**

| Key | Type | Description |
|-----|------|-------------|
| `user` | object / null | User profile from the server (`id`, `email`, `is_verified`, `current_streak`, `max_streak`, `total_xp`, `level`) |
| `token` | string / null | JWT bearer token |
| `isAuthenticated` | boolean | Derived from token presence |
| `hasOnboarded` | boolean | Set to true after completing onboarding |
| `intention` | string / null | User's chosen intention from onboarding |

**Actions:**

| Action | Description |
|--------|-------------|
| `setAuth(user, token)` | Sets user, token, and isAuthenticated after login/register |
| `completeOnboarding(intention)` | Sets hasOnboarded and intention |
| `logout()` | Clears user, token, and isAuthenticated |
| `updateUser(updates)` | Merges partial updates into user object |
| `refreshUser()` | Fetches `GET /api/auth/me` and updates user state |
| `logSession(sessionData)` | Posts to `POST /api/sessions/log` and performs optimistic XP/streak update |

The `logSession` action includes an optimistic update: it increments `current_streak` by 1, adds XP (100 for full, 50 for short), and recalculates level client-side using the same threshold lookup as the server.

### Screen Responsibilities

| Screen | File | Role |
|--------|------|------|
| Login | `screens/Login.js` | Email/password form, calls `POST /api/auth/login` |
| Register | `screens/Register.js` | Email/password/course-code form, calls `POST /api/auth/register` |
| Onboarding | `screens/Onboarding.js` | 3-step internal flow: welcome, intention picker, reminder time |
| Home | `screens/Home.js` | Dashboard: streak stat, level stat, XP progress bar, start CTA, milestone cards, retreat banner |
| Practice | `screens/Practice.js` | 5-phase guided session with timer, breath animation, play/pause/skip |
| PostSession | `screens/PostSession.js` | Session summary (duration, XP), random science insight, mood picker (1-5) |
| Progress | `screens/Progress.js` | Streak calendar, mood trend chart, XP/level card, stats grid |
| Community | `screens/Community.js` | Static placeholder: Satsang finder, global stat, XP teaser |
| Profile | `screens/Profile.js` | User info, level badge, settings display, logout button |

### Key Components

| Component | File | Description |
|-----------|------|-------------|
| BreathCircle | `components/BreathCircle.js` | Reanimated 3 animated circle that scales between 1x and 1.4x using a bezier easing curve. Breath rate is controlled by the `duration` prop; `isResting` pauses animation. |
| StreakCalendar | `components/StreakCalendar.js` | 70-cell (10 columns x 7 rows) grid where each cell represents one day. Practiced days are filled indigo; today has a border highlight. |

---

## Backend Architecture

### Server Entry

`server/src/index.js` initializes a Fastify instance with three plugins:

| Plugin | Purpose |
|--------|---------|
| `@fastify/postgres` | PostgreSQL connection pool via `DATABASE_URL` |
| `@fastify/redis` | Redis client via `REDIS_URL` |
| `@fastify/jwt` | JWT signing/verification via `JWT_SECRET` |

An `authenticate` decorator is registered that calls `request.jwtVerify()` and is used as an `onRequest` hook on protected routes.

### Route Organization

Routes are registered as Fastify plugins with path prefixes:

| File | Prefix | Endpoints |
|------|--------|-----------|
| `routes/auth.js` | `/api/auth` | `POST /register`, `POST /login`, `GET /me`, `POST /verify-course` |
| `routes/sessions.js` | `/api/sessions` | `POST /log`, `GET /history`, `GET /streak-calendar`, `GET /mood-trend` |

A `GET /health` endpoint is registered at the root level.

### Model Pattern

Models are factory functions that accept the `pg` (Postgres plugin) instance and return an object of async query methods:

- **`models/user.js`**: `findByEmail(email)`, `create({ email, password, courseCode })`, `verifyCourse(userId, code)`
- **`models/session.js`**: `create({ userId, type, durationSeconds, hrvDelta, moodScore })`, `getUserSessions(userId)`, `updateStreak(userId, moodScore)`

Models use parameterized queries (`$1`, `$2`, ...) to prevent SQL injection.

---

## Database Schema

Defined in `database/init.sql` and auto-applied by the Docker Compose Postgres init script.

### users

| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| `id` | SERIAL | PRIMARY KEY | auto |
| `email` | VARCHAR(255) | UNIQUE NOT NULL | -- |
| `password_hash` | VARCHAR(255) | NOT NULL | -- |
| `course_code` | VARCHAR(50) | -- | NULL |
| `is_verified` | BOOLEAN | -- | FALSE |
| `current_streak` | INT | -- | 0 |
| `max_streak` | INT | -- | 0 |
| `total_xp` | INT | -- | 0 |
| `level` | INT | -- | 1 |
| `created_at` | TIMESTAMPTZ | -- | CURRENT_TIMESTAMP |

### sessions

| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| `id` | SERIAL | PRIMARY KEY | auto |
| `user_id` | INT | REFERENCES users(id) ON DELETE CASCADE | -- |
| `type` | VARCHAR(20) | NOT NULL | -- |
| `duration_seconds` | INT | NOT NULL | -- |
| `completed_at` | TIMESTAMPTZ | -- | CURRENT_TIMESTAMP |
| `hrv_delta` | INT | -- | NULL |
| `mood_score` | INT | -- | NULL |

### streaks

| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| `id` | SERIAL | PRIMARY KEY | auto |
| `user_id` | INT | REFERENCES users(id) ON DELETE CASCADE | -- |
| `practice_date` | DATE | NOT NULL, UNIQUE(user_id, practice_date) | -- |
| `is_grace_day` | BOOLEAN | -- | FALSE |

### Indices

- `idx_sessions_user_id` on `sessions(user_id)`
- `idx_streaks_user_id` on `streaks(user_id)`

### Relationships

- `sessions.user_id` -> `users.id` (many-to-one, cascade delete)
- `streaks.user_id` -> `users.id` (many-to-one, cascade delete)
- `streaks` has a composite unique constraint on `(user_id, practice_date)` to prevent duplicate day entries

---

## Authentication Flow

1. **Register**: Client sends `POST /api/auth/register` with email, password, and courseCode. Server hashes password with bcrypt (cost 10), inserts into `users`, and returns a signed JWT containing `{ id, email }`.
2. **Login**: Client sends `POST /api/auth/login`. Server looks up user by email, compares password hash with bcrypt, and returns a JWT plus the user profile.
3. **Authenticated requests**: Client includes `Authorization: Bearer <token>` header. The `authenticate` decorator calls `request.jwtVerify()`, which populates `request.user` with the decoded `{ id, email }` payload.

---

## Session Logging Flow

1. User completes a practice on the **Practice** screen (all 5 phases finish or user skips to end)
2. App navigates to **PostSession** with session type and duration as route params
3. User selects a mood (1-5); the store's `logSession` action fires
4. Client sends `POST /api/sessions/log` with `{ type, durationSeconds, moodScore }`
5. Server inserts into `sessions` table, then calls `updateStreak(userId, moodScore)`
6. `updateStreak` logic:
   - Inserts today into `streaks` (skips if already logged today)
   - Checks if yesterday exists in `streaks`; if yes, increments `current_streak`; if no, resets to 1
   - Updates `max_streak` to `GREATEST(max_streak, current_streak)`
   - Awards +100 XP
   - Checks for milestone bonuses (7-day: +200 XP, 30-day: +500 XP)
   - Awards +10 XP if mood score is present and valid
   - Recalculates `level` using the threshold CASE statement
7. Client performs an optimistic update to the Zustand store (streak +1, XP added, level recalculated)

---

## XP and Level Calculation

The level system uses non-linear XP thresholds, calculated identically on both client and server:

```
Level 1 (Seeker)          :     0 XP
Level 2 (Practitioner)    :   500 XP
Level 3 (Steady Breather) : 1,500 XP
Level 4 (Inner Circle)    : 3,500 XP
Level 5 (SKY Guide)       : 7,000 XP
Level 6 (Luminous)        : 12,000 XP
```

The server recalculates level after every XP change using a SQL CASE statement. The client mirrors this with a `getLevelFromXP` function that iterates thresholds in descending order.

Streak bonuses are awarded exactly once, only when `current_streak` equals 7 or 30 (not on subsequent days). The mood XP bonus (+10) is awarded for any valid mood score (1-5) regardless of session type.
