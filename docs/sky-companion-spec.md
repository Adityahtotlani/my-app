# SKY Companion — Full Product Specification

**Version:** 1.0
**Date:** 2026-03-29
**Type:** Mobile App (iOS + Android)
**Audience:** Post-course Art of Living practitioners

---

## 1. Vision

SKY Companion turns the post-course dropout problem into a daily habit loop. Every person who completes a SKY Breath Meditation course gets a guided, science-backed, socially reinforced daily practice environment — so the transformation they felt on day 3 of the course becomes a permanent part of their life.

---

## 2. Core User Journey

```
Complete AoL Course
       |
       v
Receive app invite (email/QR in course kit)
       |
       v
Onboarding (5 min): verify course completion, set practice time, connect wearable
       |
       v
Daily Practice Loop:
  - Open app at scheduled time
  - Run guided SKY session (20–45 min)
  - See HRV/biometric before/after delta
  - Log mood (5 sec)
  - Earn streak + XP
       |
       v
Weekly: Satsang reminder + local group map
       |
       v
Monthly: Instructor video check-in (based on streak tier)
       |
       v
Milestone unlocks → advanced content → course upgrade prompts
```

---

## 3. Feature Specification

### 3.1 Onboarding

| Screen | Content | Notes |
|--------|---------|-------|
| Welcome | App purpose, 3 bullet benefits | Skip option for returning users |
| Course Verification | Enter course completion code or connect AoL account | Unlocks full SKY audio library |
| Practice Time | Time picker + recurring reminder setup | Defaults to 6:30 AM |
| Wearable Connect | Apple Watch / Garmin / Oura pairing | Optional — skippable |
| Baseline HRV | 60-second baseline reading if wearable connected | Stored as Day 0 reference |
| Intention | "What do you want from your practice?" (5 options) | Personalizes home screen widget |

---

### 3.2 Daily Practice Mode

**Pre-session**
- Today's streak display
- HRV reading (if wearable) — compared to personal 30-day average
- Estimated session length (Short: 20 min / Full: 45 min)
- Background ambient sound selector (silence / rain / Himalayan bowl)

**Session Player**

```
Phase Structure:
┌─────────────────────────────────────────┐
│  Warming Breath Exercises (5–8 min)     │
│  ─ Kapalabhati (fast pumping breaths)  │
│  ─ Bhastrika (bellows breath)          │
├─────────────────────────────────────────┤
│  Sudarshan Kriya - Slow Cycle (8 min)  │
│  ─ Inhale 4 counts, exhale 6 counts    │
├─────────────────────────────────────────┤
│  Sudarshan Kriya - Medium Cycle (8 min)│
│  ─ Equal inhale/exhale, faster pace    │
├─────────────────────────────────────────┤
│  Sudarshan Kriya - Fast Cycle (5 min)  │
│  ─ Rapid, rhythmic Om chanting breath  │
├─────────────────────────────────────────┤
│  Rest / Integration (5 min)            │
│  ─ Lie down, eyes closed               │
└─────────────────────────────────────────┘
```

- Visual breath guide: animated expanding/contracting circle synchronized to audio cues
- Phase progress bar at top
- Skip-forward only — no rewind (preserves integrity of technique)
- Lock screen controls (play/pause, phase label)
- Background audio continues when screen locks

**Post-session**
- HRV delta card: "Your HRV improved +12ms today"
- Mood log: 1-tap emoji (5 options: drained → vibrant)
- Insight card: one science fact about what just happened physiologically
- Streak update + XP earned animation
- Share card (optional): shareable "I practiced SKY today" card for Instagram/WhatsApp

---

### 3.3 Streak & Gamification System

**XP Structure**

| Action | XP |
|--------|----|
| Complete full session | 100 XP |
| Complete short session | 50 XP |
| Log mood post-session | 10 XP |
| Attend satsang | 75 XP |
| 7-day streak | 200 XP bonus |
| 30-day streak | 500 XP bonus |

**Levels**

| Level | Name | XP Required |
|-------|------|-------------|
| 1 | Seeker | 0 |
| 2 | Practitioner | 500 |
| 3 | Steady Breather | 1,500 |
| 4 | Inner Circle | 3,500 |
| 5 | SKY Guide | 7,000 |
| 6 | Luminous | 12,000 |

**Streak Mechanics**
- Daily streak resets at midnight (user's local time)
- 1 "Grace Day" per 30 days — skip a day without breaking streak
- Streak Freeze purchasable (1 per month free, additional via XP)

---

### 3.4 HRV & Biometrics Dashboard

**Daily View**
- Pre/post HRV for each session (bar chart)
- Stress index (derived from HRV variability)
- Resting heart rate trend line

**Weekly View**
- 7-day HRV average vs. previous week
- Best practice day (highest HRV improvement)
- Sleep quality correlation (if Apple Health / Garmin sleep data available)

**All-Time View**
- HRV trend since first session (Day 0 baseline)
- Total minutes practiced
- Mood trend over time
- "Your practice by the numbers" shareable card

**Data Sources**
- Apple HealthKit (iOS)
- Garmin Health SDK
- Oura Ring API
- Manual entry fallback (no wearable)

---

### 3.5 Satsang Finder

Satsang = community group practice session, a core AoL tradition.

**Features**
- Map view: nearby satsangs plotted (volunteer-hosted, pulled from AoL events API)
- List view: date, location, host name, attendee count
- RSVP in-app → adds to device calendar
- Virtual satsang option: join a live-streamed group session from home
- Host a satsang: certified teachers can list their sessions (pending approval)
- Attendance check-in: tap "I'm here" to earn Satsang XP

**Data**
- Powered by AoL's existing event/volunteer database via API integration
- Fallback: manual community board if API not available

---

### 3.6 Instructor Check-ins

Tiered video messages from certified AoL teachers, unlocked by streak milestones.

| Streak Milestone | Content |
|-----------------|---------|
| Day 7 | "How the first week goes" — what to expect, common challenges |
| Day 21 | "You've built a habit" — deepening the practice |
| Day 40 | "The 40-day transformation" — science of neuroplasticity |
| Day 90 | "You're a practitioner now" — invitation to Part 2 course |
| Day 180 | Personalized message from a senior AoL teacher |

- Videos are 3–5 minutes, pre-recorded
- Notification triggered at milestone: "You have a message from [Teacher Name]"
- Videos accessible in "My Journey" tab after unlock

---

### 3.7 Course Upgrade Gateway

At key milestones (Day 30, Day 90), a contextual nudge appears:

```
┌──────────────────────────────────────┐
│  You've practiced 30 days in a row.  │
│                                      │
│  Thousands of practitioners say the  │
│  AoL Part 2 retreat is where the     │
│  real breakthrough happens.          │
│                                      │
│  [Browse Upcoming Retreats]          │
│  [Remind me later]                   │
└──────────────────────────────────────┘
```

- Deep links to AoL's course registration page
- Personalized by location (nearest retreat shown)

---

## 4. Screen Map

```
Tab Bar: [Home] [Practice] [Progress] [Community] [Profile]

HOME
├── Daily streak card
├── Today's practice CTA
├── HRV snapshot (if wearable)
├── Upcoming satsang (nearest)
└── Instructor message (if unlocked)

PRACTICE
├── Session type selector (Full / Short / Custom)
├── Background sound selector
├── [Start Session]
└── Session History (last 10 sessions)

PROGRESS
├── Streak calendar (GitHub-style heatmap)
├── HRV Dashboard (Daily / Weekly / All-time)
├── XP & Level card
├── Mood trend chart
└── Achievements / Badges

COMMUNITY
├── Satsang Map
├── Satsang List
├── Virtual Satsang (live schedule)
├── Host a Satsang (teachers only)
└── Global practice counter ("X people practiced today")

PROFILE
├── Name, course completion date, level
├── Wearable connections
├── Notification settings
├── Practice time settings
├── Instructor messages (archive)
└── Subscription management
```

---

## 5. Tech Stack

### Frontend
- **React Native** (Expo managed workflow) — single codebase for iOS and Android
- **Expo AV** — audio playback with background mode and lock screen controls
- **React Navigation v6** — tab + stack navigation
- **Zustand** — lightweight global state (session state, user profile, streaks)
- **React Native Reanimated 3** — breath circle animation (60fps, native driver)
- **Victory Native** — HRV and mood charts

### Backend
- **Node.js + Fastify** — REST API (lightweight, high performance)
- **PostgreSQL** — primary database (users, sessions, streaks, HRV logs)
- **Redis** — session caching, streak calculation, leaderboard
- **AWS S3** — audio file storage (SKY guided sessions, instructor videos)
- **AWS CloudFront CDN** — global audio delivery (low latency for South Asia, Latin America)

### Integrations
- **Apple HealthKit** — HRV, heart rate, sleep data (iOS)
- **Garmin Health SDK** — HRV, stress index
- **Oura Ring API** — HRV, readiness, sleep
- **AoL Events API** — satsang data (or scraped/manual if API unavailable)
- **Firebase Cloud Messaging** — push notifications (streaks, satsangs, check-ins)
- **RevenueCat** — subscription management across iOS + Android

### Auth
- **Supabase Auth** — email/password + Google OAuth
- AoL course code verification endpoint (custom, integrated with AoL's backend)

### Analytics
- **PostHog** (self-hosted) — product analytics, funnel tracking, feature flags
- **Sentry** — crash reporting

---

## 6. Business Model

| Revenue Stream | Details |
|---------------|---------|
| Free tier | 30-day trial, full access |
| Monthly subscription | $4.99/month |
| Annual subscription | $39.99/year ($3.33/month) |
| AoL course bundle | Free 12-month subscription included with any AoL course purchase |
| Course conversion (primary) | App-to-course referral drives $150–$400 course purchases; tracked via UTM |

**Unit Economics (Year 1 Target)**
- 50,000 downloads (via AoL's existing course graduate database — est. 5M+ globally)
- 15% convert to paid: 7,500 subscribers
- Avg. revenue per subscriber: $40/year
- Subscription revenue: $300,000/year
- Course conversion (5% of free users × avg. $200 course): $500,000 in driven GMV

---

## 7. Development Roadmap

### Phase 1 — MVP (12 weeks)
- [ ] Onboarding flow + course code verification
- [ ] Full SKY guided session player (audio + breath animation)
- [ ] Basic streak tracking + XP
- [ ] Session history log
- [ ] Push notification reminders
- [ ] iOS + Android builds

### Phase 2 — Biometrics (8 weeks)
- [ ] Apple HealthKit HRV integration
- [ ] Pre/post session HRV delta
- [ ] HRV dashboard (daily/weekly/all-time)
- [ ] Mood logging + trend chart

### Phase 3 — Community (8 weeks)
- [ ] Satsang map + RSVP
- [ ] Virtual satsang live stream integration
- [ ] Instructor milestone video check-ins
- [ ] Global practice counter

### Phase 4 — Growth (ongoing)
- [ ] Garmin + Oura integration
- [ ] Course upgrade gateway
- [ ] Streak freeze + grace day mechanics
- [ ] Shareable progress cards
- [ ] Multilingual support (Hindi, Spanish, French, German)

---

## 8. Key Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| AoL won't share course graduate database | Partner via AoL instructor network; launch as unofficial companion app |
| SKY audio content IP is tightly controlled | License content from AoL; use instructor-narrated re-recordings |
| Wearable HRV data quality varies by device | Show confidence indicators; make wearable optional; manual entry fallback |
| Low D30 retention (common in wellness apps) | Streak mechanics + social layer + instructor check-ins are explicitly designed to solve this |
| Competition from AoL's own Journey app | Position as practice-specific depth tool, not a general content app — complementary, not competitive |
