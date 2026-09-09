# Klyptr Studio - Product Requirements Document

**Version:** 1.0 | **Date:** September 2026 | **Status:** In Development

---

## 1. Problem Statement

- **Audience:** Introverted tech experts, faceless creators, busy professionals
- **Barrier:** Content creation requires scriptwriting → voiceover recording → B-roll sourcing → editing (1-2 weeks for MVP)
- **Core Friction:** Camera shyness, time scarcity, skill gap in editing/pacing
- **Opportunity:** 124M+ users engage with AI video tools; market $3.35B by 2034

---

## 2. Solution Overview

**All-in-one platform generating modular content assets (10-15 min end-to-end)**

| Input | Output |
|-------|--------|
| Topic/keyword + language + tone + style | Script + Voiceover + B-roll suggestions + Captions |

**Flexibility:** Users mix AI + own content (AI script + own voiceover, or own script + AI voiceover)

---

## 3. MVP Features (Phase 1)

- Script generation with tone control (beginner, professional, casual, respectful)
- AI voiceover (ElevenLabs, GPT-SoVITS) or user voice cloning with explicit consent
- B-roll suggestions + stock footage integration
- Caption auto-generation + multi-language support
- Asset export (downloadable, ready for upload)
- User dashboard + basic subscription tier

---

## 4. Future Features (Post-MVP)

- Complete video generation (automated assembly)
- Social publishing integration (YouTube, TikTok, LinkedIn)
- Template marketplace with revenue share
- White-label licensing for agencies
- Team collaboration tools (brand kits, approval workflows)
- Advanced analytics (watch time, engagement, retention by clip)

---

## 5. Microservices & Tech Stack

| Service | Purpose | Language | DB | Cache | Queue |
|---------|---------|----------|-----|-------|-------|
| **User Service** | Auth, profiles, subscriptions | Java 21/Spring Boot | PostgreSQL | Redis | — |
| **Script Service** | Content generation, tone control | TypeScript/Node.js | PostgreSQL | Redis | Kafka |
| **Voice Service** | TTS, voice cloning, voice library | Python/FastAPI | PostgreSQL | Redis | Kafka |
| **Media Service** | B-roll suggestions, image generation | TypeScript/Node.js | PostgreSQL + S3 | Redis | Kafka |
| **Asset Manager** | Storage, versioning, exports | Java 21/Spring Boot | PostgreSQL + S3 | Redis | Kafka |
| **Subscription Service** | Usage tracking, quotas, billing | Python/FastAPI | PostgreSQL | Redis | — |
| **Analytics Service** | Metrics, user activity | Python/FastAPI | TimescaleDB | — | Kafka |
| **Notification Service** | Email, webhooks, alerts | TypeScript/Node.js | PostgreSQL | — | Bull Queue |

**Frontend:** React 18 + Vite (TypeScript) | **API Gateway:** Kong | **Monitoring:** Prometheus + Grafana

---

## 6. System Architecture Diagram

![](./.assets/Architecture.jpg)

## 7. Data Flow & Caching Strategy

**Write Path (User Generates Content):**
- User input → User Service (auth) → Script Service (PostgreSQL write, Redis cache invalidation) → Kafka event

**Read Path (Fetch Assets):**
- API Gateway → Asset Manager → Redis cache check → PostgreSQL fallback → S3 presigned URL

**Cache Invalidation:**
- Script changes: invalidate script:{userId} + script:{projectId}
- Voice changes: invalidate voice:{voiceId}
- Media changes: invalidate media:suggestions:{topicId}

---

## 8. Development Roadmap

| Phase | Timeline | Key Deliverables | Success Metrics |
|-------|----------|------------------|-----------------|
| **Phase 1: MVP** | Months 1-3 | User, Script, Voice, Web UI, Basic Export | 50 users, 1K videos |
| **Phase 2: Polish & Launch** | Months 4-5 | Media Service, Asset Manager, Analytics, Voice Clone | 500 users, subscription tier |
| **Phase 3: Growth** | Months 6-9 | White-label API, Template Marketplace, Team Features | 5K users, $50K MRR |
| **Phase 4: Enterprise** | Months 10-12 | K8s deployment, SLA, Enterprise support | 50K users, enterprise revenue |

---

## 9. Non-Functional Requirements

| Requirement | Target | Rationale |
|-------------|--------|-----------|
| Video Generation Latency | <2 min | User satisfaction (script to assets) |
| API Uptime | 99.9% | SLA for paying customers |
| Script Success Rate | >95% | Quality control |
| Voice Quality (MOS) | >4.0 | Parity with ElevenLabs |
| Concurrent Users | 1000+ | Peak load during launch |
| Content Retention | 60% day-1, 30% day-30 | Viral growth potential |

---

## 10. Legal & Compliance

- **DPDP Act 2023 (India):** Explicit consent form for voice cloning + right to delete
- **Copyright:** Licensed stock libraries + AI-generated original content only
- **Data Protection:** AES-256 encryption at rest, TLS 1.3 in transit
- **GDPR:** Data subject rights (access, erasure, portability) built-in
- **Terms of Service:** Users retain content rights; platform retains usage rights for analytics only

---

## 11. Success Metrics (12-Month Target)

- **User Growth:** 1K → 50K users
- **Content Generated:** 1K → 500K videos
- **Revenue:** $0 → $500K MRR (Mix: $200K subscription + $300K white-label/API)
- **Retention:** 60% month-1, 40% month-3, 30% month-6
- **NPS Score:** 40+ by Month 9
- **Video Quality:** 95%+ user satisfaction (5-star rating)

---

## 12. Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| AI voice quality issues | ElevenLabs + GPT-SoVITS redundancy; human QA |
| Copyright/licensing disputes | Licensed stock only; user content ToS |
| Platform dependency (YouTube API changes) | Multi-platform support; downloadable exports |
| Competitive pricing pressure | Differentiate on UX + voice quality + flexibility |
| Regulatory (voice cloning laws) | Explicit consent + audit logs + data deletion guarantees |

---

**Document Owner:** Dharmaraj R | **Last Updated:** September 2026 | **Next Review:** End of Phase 1