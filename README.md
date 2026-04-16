# SKY Companion

**A daily meditation habit app for Art of Living practitioners.**

`React Native` `Expo` `Fastify` `PostgreSQL` `Redis` `Zustand`

---

## Overview

SKY Companion helps Art of Living alumni maintain a consistent daily SKY Breath Meditation practice. The app provides guided 5-phase breath sessions, a streak and XP gamification system, mood tracking, and progress visualization -- all designed to turn a one-time course experience into a lasting daily habit.

## Features

### Practice

- **Guided SKY sessions** with two modes: Full (35 min) and Short (15 min)
- **5-phase breath animation** player: Warming Breaths, Slow Cycle, Medium Cycle, Fast Cycle, and Rest & Integration
- **Animated breath circle** built with React Native Reanimated 3 that scales and pulses at the current phase's breath rate
- **Phase progress bar** showing overall session completion with labeled phase markers
- **Play/pause and skip** controls to manage session flow

### Gamification

- **XP system** awarding 100 XP per full session and 50 XP per short session
- **Non-linear level progression** across 6 levels (Seeker through Luminous)
- **Streak milestone bonuses**: +200 XP at 7-day streak, +500 XP at 30-day streak
- **Mood logging bonus**: +10 XP for recording a post-session mood score

### Progress Tracking

- **70-day streak heatmap calendar** showing practiced vs. missed days
- **Mood trend chart** (Victory Native line chart) plotting the last 14 session mood scores
- **XP and level card** with progress bar toward next level
- **Stats summary**: total sessions, average duration, personal best streak

### Onboarding

- **3-step flow**: Welcome screen with feature bullets, intention picker (5 options), and practice reminder time selector (Morning, Midday, Evening)
- **Push notification scheduling** configured during onboarding via Expo Notifications

### Home Dashboard

- **Greeting with streak and level stats**
- **XP progress bar** with distance to next level
- **Quick-start CTA** linking directly to Practice screen
- **Instructor milestone cards** unlocking at day 7, 21, 40, and 90 with teacher messages
- **Course upgrade banner** at 30-day streak with link to AoL Part 2 retreat page

### Community

- **Satsang Finder** placeholder (coming in Phase 3)
- **Global practitioner stat card** and Satsang XP teaser

### Notifications

- **Daily practice reminder** scheduled as a repeating local notification at user-chosen time
- **Android notification channel** configured with custom vibration pattern

## Screenshots

<!-- Screenshots coming soon. Add app screenshots to /docs/screenshots/ and reference them here. -->

_Screenshots coming soon._

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Mobile | React Native (Expo) | Cross-platform mobile app |
| Animation | React Native Reanimated 3 | Breath circle scaling animation |
| Navigation | React Navigation v6 | Tab navigator + stack navigators |
| State | Zustand | Client-side state management |
| Charts | Victory Native | Mood trend line chart |
| Icons | lucide-react-native | UI iconography |
| Notifications | expo-notifications | Local push notification scheduling |
| Backend | Node.js + Fastify | REST API server |
| Database | PostgreSQL 15 | Persistent data storage |
| Cache | Redis 7 | Session caching (registered, not yet utilized) |
| Auth | @fastify/jwt | JWT token signing and verification |
| Passwords | bcrypt | Password hashing |

## Architecture

SKY Companion follows a 3-tier architecture: the Expo mobile client communicates with a Fastify REST API, which reads and writes to a PostgreSQL database. Redis is provisioned for future caching needs.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full technical architecture document.

### Project Structure

```
my-app/
├── app/                           # React Native (Expo)
│   ├── App.js                     # Navigation root (auth/onboarding/main routing)
│   └── src/
│       ├── components/
│       │   ├── BreathCircle.js    # Animated breath guide (Reanimated 3)
│       │   └── StreakCalendar.js   # 70-day heatmap grid
│       ├── screens/
│       │   ├── Onboarding.js      # 3-step onboarding flow
│       │   ├── Home.js            # Dashboard with stats and milestones
│       │   ├── Practice.js        # 5-phase guided session player
│       │   ├── PostSession.js     # Mood log, XP summary, science insight
│       │   ├── Progress.js        # Calendar, mood chart, XP card, stats
│       │   ├── Community.js       # Satsang finder placeholder
│       │   ├── Profile.js         # Account info and settings
│       │   ├── Login.js           # Email/password login
│       │   └── Register.js        # Registration with course code
│       ├── services/
│       │   └── notifications.js   # Expo push notification helpers
│       └── store/
│           └── useStore.js        # Zustand store (auth, user, sessions)
├── server/                        # Fastify API
│   ├── .env.example               # Environment variable template
│   └── src/
│       ├── index.js               # Server entry, plugin registration
│       ├── routes/
│       │   ├── auth.js            # Register, login, /me, verify-course
│       │   └── sessions.js        # Log, history, streak-calendar, mood-trend
│       └── models/
│           ├── user.js            # User queries (find, create, verify)
│           └── session.js         # Session queries, streak/XP logic
├── database/
│   └── init.sql                   # PostgreSQL schema (users, sessions, streaks)
└── docker-compose.yml             # PostgreSQL 15 + Redis 7
```

## Getting Started

### Prerequisites

- Node.js 18+
- Docker and Docker Compose
- Expo CLI (`npm install -g expo-cli`) or use `npx expo`
- Expo Go app on your phone (iOS/Android) for device testing

### 1. Start the database and cache

```bash
cd /root/projects/my-app
docker compose up -d
```

This starts PostgreSQL 15 and Redis 7. The `database/init.sql` schema is automatically applied on first run.

### 2. Start the backend

```bash
cd server
cp .env.example .env   # then edit JWT_SECRET
npm install
npm run dev
```

The API will be available at `http://localhost:3000`.

### 3. Start the mobile app

```bash
cd app
npm install
npx expo start
```

Scan the QR code with Expo Go (iOS/Android), or press `i` for iOS simulator / `a` for Android emulator.

## Environment Variables

Create `server/.env` from the provided template:

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | API server port | `3000` |
| `DATABASE_URL` | PostgreSQL connection string | `postgres://sky_user:sky_password@localhost:5432/sky_companion` |
| `REDIS_URL` | Redis connection string | `redis://localhost:6379` |
| `JWT_SECRET` | Secret key for signing JWT tokens | _(must be set)_ |

## API Reference

See [docs/API.md](docs/API.md) for full request/response schemas.

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/api/auth/register` | No | Register with email, password, and course code |
| `POST` | `/api/auth/login` | No | Authenticate and receive a JWT |
| `GET` | `/api/auth/me` | JWT | Get current user profile |
| `POST` | `/api/auth/verify-course` | JWT | Verify an AoL course code |
| `POST` | `/api/sessions/log` | JWT | Log a completed practice session |
| `GET` | `/api/sessions/history` | JWT | Get last 50 sessions for the user |
| `GET` | `/api/sessions/streak-calendar` | JWT | Get practiced dates for last 70 days |
| `GET` | `/api/sessions/mood-trend` | JWT | Get last 14 mood scores as chart data |
| `GET` | `/health` | No | Server health check |

## Game Mechanics

### XP Awards

| Action | XP |
|--------|----|
| Complete a full session (35 min) | +100 |
| Complete a short session (15 min) | +50 |
| Log a mood score (1-5) | +10 |
| Reach a 7-day streak | +200 bonus |
| Reach a 30-day streak | +500 bonus |

### Levels

| Level | Name | XP Threshold |
|-------|------|-------------|
| 1 | Seeker | 0 |
| 2 | Practitioner | 500 |
| 3 | Steady Breather | 1,500 |
| 4 | Inner Circle | 3,500 |
| 5 | SKY Guide | 7,000 |
| 6 | Luminous | 12,000 |

Level is recalculated server-side after every session log using a non-linear threshold lookup.

### Instructor Milestones

Teacher messages unlock on the Home screen at streak milestones: 7 days, 21 days, 40 days, and 90 days.

## Onboarding Flow

1. **Welcome** -- app introduction with three feature highlights
2. **Intention** -- user selects their primary goal (Reduce Stress, Better Sleep, More Energy, Inner Peace, Daily Discipline)
3. **Reminder** -- user picks a daily practice time (Morning 6:30 AM, Midday 12:00 PM, Evening 7:00 PM); a recurring local notification is scheduled

## Navigation Structure

```
Not Authenticated     Authenticated (no onboarding)     Authenticated (onboarded)
─────────────────     ─────────────────────────────     ─────────────────────────
Login                 Onboarding (3 steps)               MainTabs
Register                                                  ├── Home
                                                          ├── Practice
                                                          ├── Progress
                                                          ├── Community
                                                          └── Profile
                                                         PostSession (stack overlay)
```

## Roadmap

- **Phase 2** -- Apple HealthKit HRV integration, pre/post HRV delta
- **Phase 3** -- Satsang map + RSVP, virtual satsang, global practice counter
- **Phase 4** -- Garmin/Oura integration, shareable progress cards, multilingual support

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes with clear messages
4. Push to your branch and open a Pull Request
5. Ensure all tests pass before requesting review

## License

MIT License. See [LICENSE](LICENSE) for details.
