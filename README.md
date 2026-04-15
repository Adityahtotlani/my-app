# SKY Companion

A React Native mobile app for Art of Living practitioners to maintain a daily SKY Breath Meditation habit.

## What It Does

- **Guided SKY sessions** — 5-phase breath animation player (Full 35min / Short 15min)
- **Streak & XP system** — daily streaks, non-linear level progression (Seeker → Luminous), milestone bonuses at day 7 and day 30
- **Progress tracking** — 70-day streak heatmap calendar, mood trend chart, XP level card
- **Post-session flow** — mood log (emoji), science insight card, XP summary
- **Instructor milestone cards** — teacher messages unlock at day 7, 21, 40, and 90
- **Course upgrade gateway** — contextual nudge to AoL Part 2 at day 30
- **Community tab** — Satsang finder (Phase 3)
- **Push notifications** — daily practice reminder at 6:30 AM

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | React Native (Expo) |
| Animation | React Native Reanimated 3 |
| Navigation | React Navigation v6 (tabs + stack) |
| State | Zustand |
| Charts | Victory Native |
| Backend | Node.js + Fastify |
| Database | PostgreSQL 15 |
| Cache | Redis 7 |
| Auth | JWT (via @fastify/jwt) |

## Project Structure

```
my-app/
├── app/                        # React Native (Expo)
│   ├── App.js                  # Navigation root
│   └── src/
│       ├── components/
│       │   ├── BreathCircle.js # Animated breath guide
│       │   └── StreakCalendar.js
│       ├── screens/
│       │   ├── Home.js
│       │   ├── Practice.js
│       │   ├── PostSession.js
│       │   ├── Progress.js
│       │   ├── Community.js
│       │   ├── Profile.js
│       │   ├── Login.js
│       │   └── Register.js
│       ├── services/
│       │   └── notifications.js
│       └── store/
│           └── useStore.js     # Zustand store
├── server/                     # Fastify API
│   └── src/
│       ├── index.js
│       ├── routes/
│       │   ├── auth.js         # register, login, /me
│       │   └── sessions.js     # log, history, streak-calendar, mood-trend
│       └── models/
│           ├── user.js
│           └── session.js
├── database/
│   └── init.sql                # PostgreSQL schema
└── docker-compose.yml          # Postgres + Redis
```

## Getting Started

### 1. Start the database and cache

```bash
docker compose up -d
```

### 2. Start the backend

```bash
cd server
cp .env.example .env   # fill in your values
npm install
npm run dev
```

### 3. Start the app

```bash
cd app
npm install
npx expo start
```

Scan the QR code with Expo Go (iOS/Android) or press `i` for iOS simulator / `a` for Android emulator.

## Environment Variables

Create `server/.env`:

```
PORT=3000
DATABASE_URL=postgres://sky_user:sky_password@localhost:5432/sky_companion
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-secret-here
```

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/auth/register` | — | Register with email + course code |
| POST | `/api/auth/login` | — | Login, returns JWT |
| GET | `/api/auth/me` | JWT | Current user profile |
| POST | `/api/auth/verify-course` | JWT | Verify AoL course code |
| POST | `/api/sessions/log` | JWT | Log a completed session |
| GET | `/api/sessions/history` | JWT | Last 50 sessions |
| GET | `/api/sessions/streak-calendar` | JWT | Last 70 practiced dates |
| GET | `/api/sessions/mood-trend` | JWT | Last 14 mood scores |

## XP & Levels

| Level | Name | XP Required |
|-------|------|-------------|
| 1 | Seeker | 0 |
| 2 | Practitioner | 500 |
| 3 | Steady Breather | 1,500 |
| 4 | Inner Circle | 3,500 |
| 5 | SKY Guide | 7,000 |
| 6 | Luminous | 12,000 |

Bonus XP: +200 at a 7-day streak, +500 at a 30-day streak.

## Roadmap

- **Phase 2** — Apple HealthKit HRV integration, pre/post HRV delta
- **Phase 3** — Satsang map + RSVP, virtual satsang, global practice counter
- **Phase 4** — Garmin/Oura integration, shareable progress cards, multilingual support
