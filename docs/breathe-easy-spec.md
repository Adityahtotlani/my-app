# Breathe Easy — Full Product Specification

**Version:** 1.0
**Date:** 2026-03-29
**Type:** Mobile App (iOS + Android)
**Audience:** Stress-aware adults aged 25–45, new to meditation

---

## 1. Vision

Breathe Easy is the front door to the Art of Living ecosystem. It meets skeptical, busy, overwhelmed adults exactly where they are — offering a jargon-free, science-first 30-day wellbeing journey that delivers real results and naturally converts users into AoL course attendees. Every design decision prioritizes trust, simplicity, and measurable calm.

---

## 2. Core User Journey

```
User searches "stress relief app" or gets referred by friend
       |
       v
Downloads Breathe Easy (free)
       |
       v
Onboarding (3 min): stress profile quiz, set daily goal (5 / 10 / 15 min)
       |
       v
Day 1–6: Foundation Phase
  - 5–7 min daily sessions
  - Simple breathwork + short guided meditation
  - Daily "Why It Works" science card
  - Stress check-in (10 seconds)
       |
       v
Day 7 nudge: "Curious to go deeper?" — soft intro to SKY
       |
       v
Day 7–20: Discovery Phase
  - Sessions grow to 10–12 min
  - Introduce Sudarshan Kriya preview (lite version, not full technique)
  - Unlock first wisdom talk (3 min)
  - Invite to free AoL intro session (in-app CTA)
       |
       v
Day 14 nudge: "You've reduced your stress score by X% — here's what's next"
       |
       v
Day 21–30: Integration Phase
  - Full 15-min sessions
  - Sleep and energy tracking added
  - Community challenge unlocks
  - Day 30 nudge: "You're ready for the full SKY course"
       |
       v
Post Day 30: Ongoing practice mode + paid subscription option
```

---

## 3. Feature Specification

### 3.1 Onboarding

No account required to start. Email/phone collected only at Day 3 (after they've experienced value).

**Screen 1 — Stress Profile Quiz (4 questions)**

```
Q1: "How would you describe your stress right now?"
    😰 Overwhelmed  😤 Tense  😐 Managing  😌 Mostly calm

Q2: "What's draining you most?"
    Work  Relationships  Sleep  Health  Everything

Q3: "How much time can you commit daily?"
    5 min  10 min  15 min

Q4: "Have you tried meditation before?"
    Never  A few times  Regularly (but need a reset)
```

**Screen 2 — Your personalized plan**
- "Based on your answers, here's your 30-day plan"
- Shows session length, time of day, expected outcome
- Outcome framed scientifically: "In 30 days, studies show practitioners report 40% lower anxiety scores"

**Screen 3 — Pick your daily reminder time**
- Time picker
- "We'll remind you — no spam, just one nudge"

**Screen 4 — Begin Day 1** (immediate, no friction)

---

### 3.2 Daily Session Structure

Each session has three micro-layers:

```
┌──────────────────────────────────────┐
│  1. ARRIVE (1–2 min)                 │
│  ─ Body scan: notice tension         │
│  ─ Prompt: "Rate your stress 1–10"  │
├──────────────────────────────────────┤
│  2. PRACTICE (3–12 min)              │
│  ─ Breathwork exercise (varies)      │
│  ─ Short guided meditation           │
├──────────────────────────────────────┤
│  3. LAND (1 min)                     │
│  ─ Prompt: "Rate your stress 1–10"  │
│  ─ Science card: why this worked     │
│  ─ Streak + progress update          │
└──────────────────────────────────────┘
```

**Session Types by Phase**

| Day Range | Breathwork | Meditation | Duration |
|-----------|-----------|------------|----------|
| 1–6 | Box breathing (4-4-4-4) | Body scan | 5–7 min |
| 7–13 | Extended exhale (4-7-8) | Guided visualization | 8–10 min |
| 14–20 | Alternate nostril (Nadi Shodhan lite) | Open awareness | 10–12 min |
| 21–30 | Bhastrika intro + SKY preview | Mantra-free silent sit | 12–15 min |

**Visual Design of Breath Guide**
- Large animated circle: expands on inhale, contracts on exhale
- Phase label below circle: "Inhale... Hold... Exhale... Hold..."
- Color shifts with phase (cool blue → warm amber)
- No text clutter during practice — minimal UI

---

### 3.3 The "Why It Works" Science Card System

After every session, one plain-English science card appears. This is a key differentiator — it builds trust and curiosity without feeling like a lecture.

**Examples:**

> **"Slow exhales calm your nervous system"**
> When you exhale longer than you inhale, you activate the vagus nerve — your body's built-in relaxation switch. Your heart rate slows. Cortisol drops. That calm you feel? That's physiology, not placebo.

> **"Your brain just got a wash"**
> During deep rest states (like the one you just entered), your glymphatic system — your brain's cleaning crew — activates and flushes out stress hormones and cellular waste. That's why you feel clearer after meditation.

> **"Rhythmic breathing syncs your brain waves"**
> Cyclical breathing (like Sudarshan Kriya) creates coherence between your left and right brain hemispheres. Studies at Stanford and Harvard show this dramatically reduces anxiety and improves emotional regulation.

**Card library:** 90 unique cards (3 per day for 30 days). Cards rotate after 30 days. Users can save favorites.

---

### 3.4 Stress Score Tracking

**Daily Check-in (10 seconds)**
- Pre-session: "Stress right now?" — tap 1–10
- Post-session: "Stress now?" — tap 1–10
- Stored with timestamp

**Weekly Stress Report**
- Average pre-session stress vs. post-session stress (shows session effectiveness)
- Week-over-week trend: "Your average stress this week was 5.8 — down from 7.2 last week"
- Best day of week
- "What helped most" (derived from session type correlation)

**30-Day Transformation Summary**
- Day 1 vs. Day 30 stress baseline
- Total minutes practiced
- Streak record
- "You've had X calm moments this month"
- Shareable card with blurred personal data option

---

### 3.5 Progressive Content Unlocks

Content is revealed gradually to avoid overwhelm and create forward momentum.

```
Day 1:    Unlock → Box Breathing session
Day 3:    Unlock → Sleep Wind-Down (5 min bedtime session)
Day 5:    Unlock → "Science of Stress" 3-min explainer video
Day 7:    Unlock → SKY Preview session + "What is Art of Living?" card
Day 10:   Unlock → Alternate Nostril Breathing
Day 14:   Unlock → Wisdom Talk #1 (Sri Sri on stress, 3 min, subtitled)
Day 21:   Unlock → "Community Challenge" — practice with others
Day 30:   Unlock → Full SKY course invite + certificate of completion
```

**Locked content UI:** Greyed-out with "Unlocks Day X" label — creates anticipation, not frustration.

---

### 3.6 Course Conversion Gateway

Three conversion touchpoints, each contextual and data-driven:

**Day 7 — Soft Introduction**
```
┌─────────────────────────────────────────┐
│  "You've built a 7-day practice."       │
│                                         │
│  Most people stop here. But there's a  │
│  technique so powerful it has 100+      │
│  peer-reviewed studies behind it.       │
│                                         │
│  Interested? Join a FREE 1-hour intro. │
│  [See Upcoming Sessions]  [Not yet]     │
└─────────────────────────────────────────┘
```

**Day 14 — Social Proof**
```
┌─────────────────────────────────────────┐
│  Your stress score dropped 28% in      │
│  14 days. Here's what people say       │
│  happens when they do the full course: │
│                                         │
│  "I felt like I got a reboot."         │
│  — Priya, 34, Mumbai                   │
│                                         │
│  [Watch 3 Stories]  [Skip]             │
└─────────────────────────────────────────┘
```

**Day 30 — Direct Offer**
```
┌─────────────────────────────────────────┐
│  30 days. You showed up.               │
│                                         │
│  SKY Breath Meditation is the full     │
│  technique this app was built on.      │
│  3 days. Life-changing.                │
│                                         │
│  As a Breathe Easy graduate, you get  │
│  $30 off your first AoL course.        │
│                                         │
│  [Claim Your Discount]  [Continue App] │
└─────────────────────────────────────────┘
```

---

### 3.7 Community Challenges

Unlocked at Day 21. Light social layer — no social feed, no follower counts.

**Features**
- Monthly themed challenge (e.g., "7 Days of Morning Calm", "Sleep Reset Week")
- See aggregated stats: "4,230 people are doing this challenge with you"
- Anonymous leaderboard (opt-in): top streaks in your country
- Challenge completion badge added to profile
- Group accountability: opt-in daily nudge showing "X friends practiced today" (if contacts use app)

---

### 3.8 Sleep & Energy Tracking

Unlocked Day 21. Two 5-second daily check-ins (optional):

- **Morning:** "Energy on waking? 1–10"
- **Evening:** "Sleep quality last night? 1–10"

Correlated with practice data:
- "On days you practice, your morning energy averages 7.2 vs. 5.1 on rest days"

No wearable required — entirely self-reported. Kept simple by design.

---

## 4. Screen Map

```
Tab Bar: [Home] [Practice] [Progress] [Explore] [Profile]

HOME
├── Day counter + streak
├── Today's session card (CTA)
├── Stress score mini-chart (last 7 days)
├── Unlocked content notification badge
└── Challenge progress (Day 21+)

PRACTICE
├── Today's session (auto-queued)
├── Session player
│   ├── Breath animation
│   ├── Audio guide
│   ├── Phase progress bar
│   └── Pre/post stress tap
├── Session library (unlocked sessions)
└── Sleep Wind-Down shortcut

PROGRESS
├── 30-day calendar heatmap
├── Stress trend chart (pre vs post)
├── Sleep + energy chart (Day 21+)
├── Weekly report card
├── 30-day transformation summary
└── Achievements + badges

EXPLORE
├── Science cards (saved + browsable)
├── Wisdom talks (unlocked videos)
├── "What is SKY?" explainer
├── Free AoL intro session finder
└── Course upgrade CTA (Day 7+)

PROFILE
├── Name, Day count, streak record
├── Stress profile (from onboarding)
├── Daily reminder settings
├── Notification preferences
└── Subscription management
```

---

## 5. Tech Stack

### Frontend
- **React Native** (Expo managed workflow) — iOS + Android from one codebase
- **Expo AV** — background audio playback for sessions
- **React Native Reanimated 3** — smooth breath circle animations (native thread)
- **React Navigation v6** — tab + modal + stack navigation
- **Zustand** — global state (session progress, streaks, unlocks, stress scores)
- **Victory Native** — stress trend charts, heatmap calendar
- **Expo Notifications** — daily reminder push notifications

### Backend
- **Node.js + Fastify** — REST API
- **PostgreSQL** — users, sessions, stress scores, unlock progress
- **Redis** — streak logic, challenge leaderboards, daily content scheduling
- **AWS S3** — audio session files, science card images, wisdom talk videos
- **AWS CloudFront** — global CDN (critical for India/LatAm offline caching)

### Offline Support
- **Expo SQLite** — local session cache and progress sync
- Audio files pre-downloaded on Wi-Fi for offline playback
- Stress scores queued locally and synced when online
- Full Day 1–7 content available offline out of the box

### Auth
- **Supabase Auth** — email/phone OTP (no password friction)
- Delayed: auth prompted at Day 3, not Day 1

### Analytics & Growth
- **PostHog** — funnel tracking (onboarding drop-off, Day 7 conversion rate, course CTA taps)
- **Branch.io** — deep linking for referral program and course discount codes
- **Sentry** — crash reporting
- **RevenueCat** — subscription management

### Localization
- **i18next** — string translations
- **Phase 1 languages:** English, Hindi
- **Phase 2:** Spanish, Portuguese, French, German, Arabic

---

## 6. Business Model

| Revenue Stream | Details |
|---------------|---------|
| Free (30-day journey) | Full access, no credit card |
| Monthly subscription | $2.99/month — unlocks post-Day 30 content + premium session library |
| Annual subscription | $19.99/year |
| Course conversion (primary KPI) | $30 discount code drives AoL course registrations ($150–$400 each); tracked per user |
| AoL white-label option | AoL can rebrand/embed as their official beginner app (B2B license deal) |

**Unit Economics (Year 1 Target)**

| Metric | Target |
|--------|--------|
| Downloads | 200,000 (India + US + UK launch) |
| D7 retention | 45% (vs. 25% industry avg — achievable via streak mechanics) |
| D30 completion | 12% = 24,000 users |
| Paid conversion (post D30) | 8% = 1,920 subscribers |
| Subscription revenue | ~$38,000/year |
| Course conversion (3% of D30 completers) | 720 courses × avg. $200 = $144,000 in driven GMV |
| AoL revenue share on course conversions | 10% = $14,400 |

**Note:** Subscription revenue is secondary. The primary business case is course conversion GMV, which makes this app fundable as an AoL growth channel.

---

## 7. Development Roadmap

### Phase 1 — MVP (10 weeks)
- [ ] Onboarding quiz + personalized plan
- [ ] 30-day session library (Days 1–30 content)
- [ ] Session player (audio + breath animation + pre/post stress)
- [ ] Streak tracking + unlock system
- [ ] Science card library (30 cards minimum)
- [ ] Push notification reminders
- [ ] Basic progress screen (heatmap + stress chart)
- [ ] iOS + Android builds

### Phase 2 — Conversion Layer (6 weeks)
- [ ] Day 7, 14, 30 course conversion modals
- [ ] "What is SKY?" explainer content
- [ ] Free AoL intro session finder (location-based)
- [ ] Discount code deep linking (Branch.io)
- [ ] Wisdom talk video player

### Phase 3 — Community & Retention (8 weeks)
- [ ] Sleep + energy tracking
- [ ] Monthly community challenges
- [ ] Weekly stress report card
- [ ] 30-day transformation summary + shareable card
- [ ] Referral program

### Phase 4 — Global Scale (ongoing)
- [ ] Hindi + Spanish + Portuguese localization
- [ ] Offline-first optimization for low-bandwidth markets
- [ ] Regional pricing (India: ₹99/month, Brazil: R$9.99/month)
- [ ] AoL white-label / co-branding negotiation

---

## 8. Key Differentiators vs. Calm / Headspace

| Feature | Calm | Headspace | Breathe Easy |
|---------|------|-----------|-------------|
| Science cards after sessions | No | No | Yes |
| Structured 30-day journey | Partial | Yes | Yes |
| Stress score tracking | No | No | Yes |
| Course conversion pathway | No | No | Yes |
| Offline-first | Partial | No | Yes |
| Regional pricing | No | Partial | Yes |
| No spiritual jargon | Yes | Yes | Yes |
| SKY technique preview | No | No | Yes |
| Free full 30 days | No | No | Yes |

---

## 9. Key Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Low D7 retention (industry avg is ~25%) | Daily unlocks + science cards create "what's next?" pull; reminder notification is personalized, not generic |
| Course conversion rate is low | Soft-sell framing (data-driven, testimonials, not pushy); 3 touchpoints across 30 days vs. one hard ask |
| Content fatigue (30 days is a long time) | Variety in session types; unlocks maintain novelty; Sleep Wind-Down adds a second daily use case |
| AoL brand association risks (cult allegations) | App positioned as "backed by AoL science" not "by AoL" in early marketing; independent brand identity |
| Crowded market (Calm, Headspace, Insight Timer) | Niche: 30-day stress-relief journey with science explanations and a clear endpoint — not a content library |
