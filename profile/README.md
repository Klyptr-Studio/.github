<div align="center">

# 🎬 Klyptr Studio
### The AI-Powered Modular Content Engine for Tech Creators & Professionals

<p align="center">
  <b>Turn raw ideas into studio-grade video assets in under 15 minutes.</b><br/>
  Scripting • Voice Synthesis • Contextual B-Roll • Dynamic Captions • Automated Assembly
</p>

[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-blue.svg?style=for-the-badge)](LICENSE)
[![Architecture: Event-Driven](https://img.shields.io/badge/Architecture-Event--Driven%20Microservices-8A2BE2?style=for-the-badge&logo=apachekafka)](https://github.com/Klyptr-Studio)
[![Status: In Active Development](https://img.shields.io/badge/Status-Phase%201%20MVP-brightgreen?style=for-the-badge)](https://github.com/Klyptr-Studio)
[![Gateway: Kong](https://img.shields.io/badge/Gateway-Kong-11C2B0?style=for-the-badge&logo=kong)](https://github.com/Klyptr-Studio)

<br/>

<!-- GitHub Achievements Showcase -->
<table>
  <tr>
    <td align="center" width="16%">
      <a href="https://githubachievements.com/#galaxy-brain">
        <img src="https://githubachievements.com/images/badges/GalaxyBrain.png" width="56" height="56" alt="Galaxy Brain"/><br/>
        <sub><b>Galaxy Brain</b></sub>
      </a>
    </td>
    <td align="center" width="16%">
      <a href="https://githubachievements.com/#pair-extraordinaire">
        <img src="https://githubachievements.com/images/badges/PairExtraordinaire.png" width="56" height="56" alt="Pair Extraordinaire"/><br/>
        <sub><b>Pair Extraordinaire</b></sub>
      </a>
    </td>
    <td align="center" width="16%">
      <a href="https://githubachievements.com/#pull-shark">
        <img src="https://githubachievements.com/images/badges/PullShark.png" width="56" height="56" alt="Pull Shark"/><br/>
        <sub><b>Pull Shark</b></sub>
      </a>
    </td>
    <td align="center" width="16%">
      <a href="https://githubachievements.com/#quickdraw">
        <img src="https://githubachievements.com/images/badges/QuickDraw_SkinTone1.png" width="56" height="56" alt="Quickdraw"/><br/>
        <sub><b>Quickdraw</b></sub>
      </a>
    </td>
    <td align="center" width="16%">
      <a href="https://githubachievements.com/#starstruck">
        <img src="https://githubachievements.com/images/badges/StarStruck_SkinTone1.png" width="56" height="56" alt="Starstruck"/><br/>
        <sub><b>Starstruck</b></sub>
      </a>
    </td>
    <td align="center" width="16%">
      <a href="https://githubachievements.com/#public-sponsor">
        <img src="https://githubachievements.com/images/badges/PublicSponsor.png" width="56" height="56" alt="Public Sponsor"/><br/>
        <sub><b>Public Sponsor</b></sub>
      </a>
    </td>
  </tr>
</table>

<br/>

</div>

---

## ⚡ Executive Summary

Traditional short-form and educational video production is notoriously fragmented: drafting scripts, recording pristine voiceovers, hunting for contextual B-roll, keyframing animations, and syncing captions easily consumes **1 to 2 weeks per clip**. For introverted domain experts, camera-shy engineers, and busy founders, this high-friction production loop is the single largest bottleneck to audience growth.

**Klyptr Studio** replaces that manual overhead with an **enterprise-grade, event-choreographed microservices platform**. By orchestrating specialized LLMs, state-of-the-art neural voice synthesis (MOS > 4.0), and semantic media intelligence, Klyptr delivers **production-ready modular assets in 10 to 15 minutes end-to-end**.

Creators enjoy full hybrid flexibility:
- 💡 **AI Script + Own Voiceover**
- 🎙️ **Own Script + Neural Voice Synthesis**
- ⚡ **Zero-to-One Autonomous Assembly**

---

## 🏗️ System Architecture & Data Flow

Klyptr Studio is architected around an **event-driven choreography pattern** powered by **Apache Kafka**, with high-performance edge routing via **Kong API Gateway** and a unified multi-tier caching layer (Redis L2 + PostgreSQL persistent storage).

```mermaid
flowchart TD
    subgraph ClientLayer["🌐 Client Layer"]
        Client["React 18 + Vite Web App<br/>(TypeScript & Tailwind CSS)"]
    end

    subgraph EdgeLayer["🛡️ Ingress & Edge Gateway"]
        Gateway["Kong API Gateway<br/>(JWT Auth, Rate Limiting & SSL)"]
    end

    subgraph CoreServices["⚙️ Synchronous Core Services"]
        UserService["User Service<br/>(Java 21 / Spring Boot 3)"]
        SubService["Subscription Service<br/>(Python 3.11 / FastAPI)"]
        RedisSession[("Redis Cache<br/>(User Sessions & Quotas)")]
    end

    subgraph EventMesh["⚡ Event Streaming Backbone"]
        Kafka{{"Apache Kafka Event Bus<br/>(Distributed Event Topics)"}}
    end

    subgraph PipelineServices["🎬 Asynchronous Content Generation Pipeline"]
        ScriptService["Script Service<br/>(Node.js / TypeScript / OpenAI)"]
        VoiceService["Voice Service<br/>(Python / FastAPI / ElevenLabs)"]
        MediaService["Media Service<br/>(Node.js / TypeScript / Runway / FFmpeg)"]
        NotifyService["Notification Service<br/>(Node.js / TypeScript / Bull Queue)"]
    end

    subgraph StorageDelivery["📦 Storage, Assembly & Delivery"]
        AssetManager["Asset Manager<br/>(Java 21 / Spring Boot 3)"]
        PostgresDB[("PostgreSQL 15<br/>(Persistent Relational Data)")]
        RedisL2[("Redis 7 L2 Cache<br/>(Sub-50ms Read Layer)")]
        S3Storage[("AWS S3 Object Storage<br/>(Versioned Media & Signed URLs)")]
        VideoPack["📦 Studio-Grade Video Pack<br/>(Script + Voice + B-Roll + Captions)"]
    end

    %% Client Ingress
    Client -->|"HTTPS / WSS"| Gateway
    Gateway -->|"Route: /api/users"| UserService
    Gateway -->|"Route: /api/subscriptions"| SubService
    Gateway -->|"Route: /api/assets"| AssetManager

    %% Sync State Management
    UserService <--> RedisSession
    SubService <--> RedisSession
    UserService -->|"Emit: script.requested"| Kafka

    %% Asynchronous Choreography Pipeline
    Kafka -->|"Consume: script.requested"| ScriptService
    ScriptService -->|"Emit: script.generated"| Kafka

    Kafka -->|"Consume: script.generated"| VoiceService
    VoiceService -->|"Emit: voice.generated"| Kafka

    Kafka -->|"Consume: voice.generated"| MediaService
    MediaService -->|"Emit: media.ready"| Kafka

    Kafka -->|"Consume: media.ready"| AssetManager
    AssetManager -->|"Emit: asset.compiled"| Kafka
    Kafka -->|"Consume: asset.compiled"| NotifyService

    %% Persistence & Delivery
    AssetManager <--> PostgresDB
    AssetManager <--> RedisL2
    AssetManager -->|"Persist Media & Generate Signed URLs"| S3Storage
    S3Storage --> VideoPack
    VideoPack -.->|"Direct Secure Download"| Client

    %% Visual Styling
    classDef client fill:#eef2ff,stroke:#6366f1,stroke-width:2px;
    classDef edge fill:#f0fdfa,stroke:#0d9488,stroke-width:2px;
    classDef sync fill:#fdf4ff,stroke:#c026d3,stroke-width:2px;
    classDef kafka fill:#fff7ed,stroke:#ea580c,stroke-width:3px;
    classDef worker fill:#eff6ff,stroke:#2563eb,stroke-width:2px;
    classDef storage fill:#f0fdf4,stroke:#16a34a,stroke-width:2px;
    classDef pack fill:#fefce8,stroke:#ca8a04,stroke-width:2px;

    class Client client;
    class Gateway edge;
    class UserService,SubService,RedisSession sync;
    class Kafka kafka;
    class ScriptService,VoiceService,MediaService,NotifyService worker;
    class AssetManager,PostgresDB,RedisL2,S3Storage storage;
    class VideoPack pack;
```

<div align="center">
  <img src="./.assets/Architecture.jpg" alt="Klyptr Studio System Architecture" width="90%" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);"/>
  <br/>
  <sub><i>Figure 1: Event-driven choreography and microservices data pipeline</i></sub>
</div>

<br/>

### 🔄 Data Flow Lifecycle

#### ✍️ Write Path (Autonomous Generation)
1. **User Request:** Creator submits project parameters (topic, language, tone, voice preferences) via the **React 18 Web Studio**.
2. **Auth & Quotas:** **Kong API Gateway** routes to **User Service** for JWT verification and **Subscription Service** for real-time quota validation.
3. **Event Ingestion:** **User Service** writes job metadata to PostgreSQL and publishes `script.requested` to the **Apache Kafka Event Bus**.
4. **Script Generation:** **Script Service** consumes the event, invokes OpenAI with custom tone templates, stores the script, invalidates `script:{userId}` cache, and emits `script.generated`.
5. **Voice Synthesis:** **Voice Service** consumes `script.generated`, synthesizes audio via ElevenLabs or GPT-SoVITS (MOS > 4.0), caches the audio vector, and emits `voice.generated`.
6. **Media Intelligence:** **Media Service** consumes `voice.generated`, ranks contextual B-roll clips and AI imagery via Runway ML & stock footage APIs, and emits `media.ready`.
7. **Asset Assembly:** **Asset Manager** downloads media parts, encodes timeline assets, uploads to AWS S3, and emits `asset.compiled`.
8. **Notification:** **Notification Service** consumes `asset.compiled` and triggers real-time UI webhooks and email notifications.

#### 📖 Read Path (Sub-50ms Delivery)
1. Client requests project assets via `GET /api/assets/{projectId}`.
2. **Kong API Gateway** routes directly to **Asset Manager**.
3. **Asset Manager** performs an L2 cache lookup:
   - **Cache Hit:** Returns cached metadata and pre-signed S3 URLs immediately.
   - **Cache Miss:** Reads from PostgreSQL, repopulates Redis with a 2-hour TTL, and generates secure, pre-signed AWS S3 download URLs.

#### ⚡ Cache Invalidation Strategy
- **Script Changes:** Invalidate `script:{userId}` and `script:{projectId}`.
- **Voice Changes:** Invalidate `voice:{voiceId}` and audio cache vectors.
- **Media Suggestions:** Invalidate `media:suggestions:{topicId}`.

---

## 🧩 Microservices Ecosystem

Every service is developed following domain-driven design, equipped with its own containerized PostgreSQL instance, Redis cache, isolated integration tests, and multi-stage Docker build pipeline:

| Service | Responsibility | Technology Stack | Primary Data Store | Cache & Queue |
| :--- | :--- | :--- | :--- | :--- |
| **[`User-Service`](https://github.com/Klyptr-Studio/User-Service)** | Identity, JWT OAuth2, user profiles & team workspaces | `Java 21` `Spring Boot 3` | PostgreSQL 15 | Redis 7 |
| **[`Script-Service`](https://github.com/Klyptr-Studio/Script-Service)** | Prompt engineering, multi-language translation & tone steering | `TypeScript` `Node.js` `OpenAI` | PostgreSQL 15 | Redis 7 • Kafka |
| **[`Voice-Service`](https://github.com/Klyptr-Studio/Voice-Service)** | Neural TTS, consent-driven voice cloning & MOS QA scoring | `Python 3.11` `FastAPI` | PostgreSQL 15 | Redis 7 • Kafka |
| **[`Media-Service`](https://github.com/Klyptr-Studio/Media-Service)** | Semantic B-roll ranking, AI image upscaling & FFmpeg pipelines | `TypeScript` `Node.js` `Runway` | PostgreSQL 15 + AWS S3 | Redis 7 • Kafka |
| **[`Asset-Manager`](https://github.com/Klyptr-Studio/Asset-Manager)** | Timeline compilation, export encoding & asset lifecycle versioning | `Java 21` `Spring Boot 3` | PostgreSQL 15 + AWS S3 | Redis 7 • Kafka |
| **[`Subscription-Service`](https://github.com/Klyptr-Studio/Subscription-Service)**| Stripe webhook automation, plan quotas & usage guardrails | `Python 3.11` `FastAPI` | PostgreSQL 15 | Redis 7 |
| **[`Analytics-Service`](https://github.com/Klyptr-Studio/Analytics-Service)** | Time-series ingestion, user retention & generation latency | `Python 3.11` `FastAPI` | TimescaleDB | Redis 7 • Kafka |
| **[`Notification-Service`](https://github.com/Klyptr-Studio/Notification-Service)**| Real-time push, async job queues & transactional emails | `TypeScript` `Node.js` `SendGrid`| PostgreSQL 15 | Bull Queue • Redis |

---

## 🛠️ Developer Tooling & Starter Templates

To enforce consistency across polyglot microservice boundaries, Klyptr Studio maintains production-grade starter templates and CLI automation:

```
klyptr-studio/
├── ☕ template-springboot-microservice   ── Spring Boot 3.2, Java 21, JPA, Redis, Docker
├── 🐍 template-python-microservice       ── FastAPI, SQLAlchemy 2.0 Async, Pydantic v2
├── 🟩 template-nodejs-microservice       ── Express, TypeScript, pg.Pool, Zod, Vitest
└── ⚛️ template-react-microservice        ── React 18, Vite, TypeScript, Tailwind CSS
```

### Instant Service Scaffolding via CLI
Initialize and register any new microservice in seconds with our unified initializer:
```bash
# Scaffold and push a new microservice instantly
init-klyptr-studio-microservice python "Billing Engine"
init-klyptr-studio-microservice nodejs "Thumbnail Service"
init-klyptr-studio-microservice springboot "Audit Log Service"
init-klyptr-studio-microservice react "Creator Studio Web"
```

---

## 🎯 Non-Functional Specifications & SLA

```
┌──────────────────────────────────────┬──────────────────────────────────────┐
│ Metric / SLA                         │ Target Specification                 │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ End-to-End Asset Generation Latency  │ < 2 Minutes (Script to Final Pack)   │
│ Service API Availability             │ 99.9% Production Uptime SLA          │
│ Script Generation Success Rate       │ > 95% First-Pass Acceptance          │
│ Neural Voice Quality (MOS Score)     │ > 4.0 (Parity with ElevenLabs)       │
│ Peak Concurrency Support             │ 1,000+ Concurrent Generation Streams │
│ Encryption Standards                 │ AES-256 (At Rest), TLS 1.3 (Transit) │
│ Regulatory Compliance                │ DPDP Act 2023 (India) & GDPR Ready   │
└──────────────────────────────────────┴──────────────────────────────────────┘
```

---

## 🗺️ Product Roadmap

```mermaid
flowchart LR
    P1["🚀 Phase 1: MVP (Months 1-3)\n• Core Microservices\n• Script & Voice Pipeline\n• Web Studio Dashboard\n• 50 Pilot Creators"] 
    --> P2["💎 Phase 2: Polish & Launch (Months 4-5)\n• Media & Asset Manager\n• Voice Cloning Module\n• TimescaleDB Analytics\n• Public Tier Launch"]
    --> P3["📈 Phase 3: Growth (Months 6-9)\n• Creator Marketplace\n• Team Brand Kits\n• Social Auto-Publishing\n• 5,000+ Active Users"]
    --> P4["🏢 Phase 4: Enterprise (Months 10-12)\n• Multi-Region Kubernetes\n• White-Label REST SDK\n• 99.99% Enterprise SLA\n• Custom LLM Fine-Tuning"]
    
    style P1 fill:#eef2ff,stroke:#6366f1,stroke-width:2px;
    style P2 fill:#f0fdf4,stroke:#22c55e,stroke-width:2px;
    style P3 fill:#fefce8,stroke:#eab308,stroke-width:2px;
    style P4 fill:#faf5ff,stroke:#a855f7,stroke-width:2px;
```

---

## 🛡️ Security, Privacy & Compliance

- **Consent-Driven Voice Cloning:** Strict cryptographic voice sample verification ensuring non-repudiation and compliance with the **Digital Personal Data Protection (DPDP) Act 2023** and **GDPR**.
- **Data Sovereignty & Right to Erasure:** Complete programmatic deletion guarantees across Redis caches, PostgreSQL metadata, and S3 audio vectors.
- **Copyright Sanitization:** Commercial-use stock licensing integration paired exclusively with original synthetic outputs to insulate creators from copyright strikes.

---

## 🤝 Engineering Community & Contributions

Klyptr Studio thrives on engineering excellence, rigorous review standards, and open collaboration.

<div align="center">

[![Explore GitHub Achievements](https://img.shields.io/badge/GitHub_Achievements-Explore_Badges-orange?style=for-the-badge&logo=github)](https://githubachievements.com/)
[![Klyptr Organization](https://img.shields.io/badge/Organization-Klyptr--Studio-black?style=for-the-badge&logo=github)](https://github.com/Klyptr-Studio)

<br/>

<sub>Built with ❤️ by the <b>Klyptr Studio Engineering Team</b> • © 2026 Klyptr Studio. All rights reserved.</sub>

</div>
