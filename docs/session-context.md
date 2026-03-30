# Session Context — 2026-03-30

## What We Did

1. **Initialized git repo** at `/root/projects/my-app` with HTTPS remote: `https://github.com/Adityahtotlani/my-app.git`

2. **Researched Art of Living Foundation**
   - Founded 1981 by Gurudev Sri Sri Ravi Shankar
   - Active in 180+ countries, 500M+ people reached
   - Flagship technique: Sudarshan Kriya (SKY Breath Meditation) — 100+ peer-reviewed studies
   - Existing apps: AoL Journey App (4.6★, $5.99/mo) and Sattva (Vedic-focused, premium)
   - Key gap: no dedicated daily practice app for graduates, weak beginner onboarding

3. **Produced two full app proposals + specs**

---

## App 1: SKY Companion (`docs/sky-companion-spec.md`)

**Problem:** Post-course practitioners drop their daily SKY practice with no app support.

**Solution:** Guided daily SKY session player + habit loop for course graduates.

**Key Features:**
- Phase-by-phase guided SKY audio (warm-up → slow → medium → fast → rest)
- Animated breath circle, lock screen controls, background audio
- HRV biometrics (Apple Watch, Garmin, Oura) — pre/post session delta
- 6-tier XP leveling: Seeker → Luminous
- Streak mechanics: Grace Days, Streak Freezes
- Satsang Finder: map-based local group sessions + virtual option
- Instructor milestone video check-ins (Day 7, 21, 40, 90, 180)
- Course upgrade gateway at Day 30 + Day 90

**Stack:** React Native (Expo) + Fastify + PostgreSQL + Redis + AWS S3/CloudFront + RevenueCat + Supabase Auth

**Revenue:** $4.99/mo or $39.99/yr; primary driver = course conversion GMV ($500K Year 1 target)

**Roadmap:** 4 phases — MVP (12 wks) → Biometrics (8 wks) → Community (8 wks) → Growth

---

## App 2: Breathe Easy (`docs/breathe-easy-spec.md`)

**Problem:** Calm/Headspace dominate beginners. AoL loses curious strangers before they ever discover SKY.

**Solution:** Jargon-free 30-day stress-relief journey that funnels users into AoL courses.

**Key Features:**
- 4-question stress profile quiz onboarding, no account until Day 3
- 3-phase journey: Foundation (Days 1–6) → Discovery (Days 7–20) → Integration (Days 21–30)
- Session structure: Arrive → Practice → Land (pre/post stress 1–10 tap)
- 90 "Why It Works" science cards (plain-English physiology after every session)
- Progressive content unlocks (Sleep Wind-Down, Wisdom Talks, SKY Preview)
- 3-stage course conversion: soft nudge Day 7, social proof Day 14, $30 discount Day 30
- Offline-first (critical for India, LatAm)
- Community challenges unlocked at Day 21

**Stack:** React Native (Expo) + Fastify + PostgreSQL + Redis + AWS S3/CloudFront + Supabase Auth + Branch.io + PostHog + RevenueCat

**Revenue:** $2.99/mo post-journey; primary KPI = AoL course conversions ($144K GMV Year 1 target)

**Roadmap:** 4 phases — MVP (10 wks) → Conversion Layer (6 wks) → Community (8 wks) → Global Scale

---

## Competitive Positioning

| Feature | Calm | Headspace | SKY Companion | Breathe Easy |
|---------|------|-----------|---------------|--------------|
| Technique-specific daily practice | No | No | Yes | No |
| Science cards post-session | No | No | Yes | Yes |
| HRV biometric tracking | No | No | Yes | No |
| Course conversion funnel | No | No | Yes | Yes |
| Offline-first | Partial | No | No | Yes |
| Free full 30-day journey | No | No | No | Yes |

---

## Next Steps (Suggested)

- [ ] Choose which app to build first
- [ ] Define database schema
- [ ] Set up Expo project scaffold
- [ ] Design wireframes / mockups
- [ ] Negotiate content licensing with AoL
