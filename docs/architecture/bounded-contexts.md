# Zhinux Bounded Contexts

- Status: Active
- Last reviewed: 2026-10-29
- Scope: Existing User/Booking boundaries and Lab 4 flow; planned gamification domains and context index

## Purpose

This document defines ownership, language, and integration rules for Zhinux bounded contexts. It preserves the existing User/Booking boundaries and Lab 4 flow, and indexes the planned gamification domain family. Its primary goal is to let contexts evolve independently without transferring domain ownership.

The [gamification context index](#gamification-domain-family-and-context-index) describes domain boundaries and concepts only; it makes no deployment decisions.

## Gamification Domain Family and Context Index

- Status: Planned domain design; no implementation or deployment topology is implied.
- Reviewed: 2026-10-29
- Module: [`zhinux-gamification`](../../zhinux-gamification/README.md)
- Domain family: **Engagement & Motivation**.

Gamification interprets authoritative activity from Zhinux business domains to provide game-like experiences across products. It owns its own policies and outcomes; it does not become part of User, Identity & Access, or Booking. The module groups ten dedicated bounded contexts with distinct models and ownership. These boundaries describe domains, not deployments.

| Subdomain | Bounded context | Authoritative responsibilities and concepts |
| --- | --- | --- |
| Program governance | Programs & Participation | Program, Participant, Enrollment, EligibilityPolicy, RuleVersion, RecurringRewardProgram; program lifecycle, scope, enrollment, eligibility, and policy publication |
| Progression | Progression | ProgressTrack, XPGrant, ParticipantProgress, LevelCurve, MasteryNode, Streak, Milestone, Unlock; non-spendable experience and advancement |
| Trust and standing | Reputation | ReputationDimension, ReputationEvidence, ReputationPolicy, ReputationAssessment, ReputationAdjustment, TrustDimension, TrustPolicy, TrustAssessment, EvidenceConfidence; evidence-based standing, disputes, decay, and corrections |
| Recognition | Achievements | AchievementDefinition, AchievementAward, Badge, Title, Collection; qualification, award uniqueness, repeatability, and revocation |
| Objectives and challenges | Missions | MissionDefinition, MissionRun, Objective, MissionParticipation, Challenge, CooperativeObjective, CheckIn; objective progress, recurrence, limited-time events, and completion |
| Competitive play | Competition | Competition, ScoreEntry, Leaderboard, Rank, Season, League, Division, Placement; scoring, cohorts, tie-breaking, finalization, promotion, and demotion |
| Virtual economy | Virtual Economy | CurrencyDefinition, Wallet, LedgerEntry, Transfer, Hold, ExchangePolicy, ExpiryLot; multiple currencies, balances, spending, transfers, exchange, expiry, and reversals |
| Reward fulfillment | Rewards & Inventory | RewardDefinition, RewardGrant, Claim, Redemption, InventoryItem, Gift, BoosterActivation, RecurrencePolicy, RewardWindow, RewardSchedule, RewardTable, RewardSelectionPolicy, CatchUpPolicy, ClaimEntitlement, ClaimRecord; catalog, grants, claims, virtual holdings, gifting, and consumption |
| Cooperative play | Play Groups | PlayGroup, Clan, Membership, GroupRole, GroupParticipation; game-specific groups, invitations, membership lifecycle, and roster facts |
| Integrity and consequences | Integrity & Sanctions | IntegritySignal, ViolationCase, PenaltyPolicy, SanctionDecision, PenaltyEffect, Restriction, RestrictionScope, EnforcementRecord, Appeal, DecisionRevision; integrity cases, penalties, temporary restrictions, appeals, and enforcement tracking |

Definitions, scheduled runs, participant progress, and issued awards are different concepts. Referencing the same participant across contexts does not establish a shared aggregate or persistence model. Detailed policies and invariants are in the [module README](../../zhinux-gamification/README.md).

### Gamification Semantic Context Map

```mermaid
flowchart LR
    User[User] -->|Subject lifecycle facts| Programs[Programs and Participation]
    Tenant[Tenant authority - intended] -->|Tenant lifecycle facts| Programs
    Source[Booking and other business domains] -->|Qualifying facts| Progress[Progression]
    Source -->|Qualified evidence| Reputation[Reputation]
    Source -->|Objective facts| Missions[Missions]
    Source -->|Scoring facts| Competition[Competition]
    Programs -->|Published policy and enrollment facts| Progress
    Programs -->|Published policy and enrollment facts| Reputation
    Programs -->|Published policy and enrollment facts| Missions
    Programs -->|Published policy and enrollment facts| Competition
    Programs -->|Published policy and enrollment facts| Achievements[Achievements]
    Programs -->|Published policy and enrollment facts| Rewards[Rewards and Inventory]
    Programs -->|Published policy and enrollment facts| Economy[Virtual Economy]
    Programs -->|Published policy and enrollment facts| Groups[Play Groups]
    Progress -->|Milestones| Achievements
    Reputation -->|Standing assessments| Achievements
    Missions -->|Completion| Achievements
    Groups -->|Roster facts| Missions
    Groups -->|Roster facts| Competition
    Achievements -->|Awards| Rewards
    Missions -->|Completion| Rewards
    Competition -->|Final placements| Rewards
    Rewards -->|Currency operation requests| Economy
    Economy -->|Movement outcomes| Rewards
    Programs -->|Policy and participation facts| Integrity[Integrity and Sanctions]
    Source -->|Integrity evidence| Integrity
    Reputation -->|Qualified assessments for explicit policies| Integrity
    Integrity -->|Effect requests and revisions| Targets[Affected gamification contexts]
    Targets -->|Enforcement acknowledgments| Integrity
    Integrity -->|Authorized external restriction requests| Access[Business or Identity access authority]
    Access -->|Acceptance and enforcement outcome| Integrity
```

Edges identify semantic contracts only. Contexts consume only outcomes enabled by explicit policies. Identity & Access governs authenticated access; it does not calculate XP, reputation, scores, or awards. Programs publishes applicable enrollment/policy facts; each downstream context owns interpretation and enforcement of its local policy. No arrow implies shared storage or a required synchronous dependency.

### Gamification Language and Currency Rules

| Concept | Meaning and boundary |
| --- | --- |
| XP | Non-spendable advancement within a Progression track |
| Level | Advancement classification from XP and a versioned level curve |
| Reputation | Evidence-based trust, quality, or reliability in a Reputation dimension; independent of XP and levels |
| Trust factor / confidence | Scoped Reputation assessment / strength of supporting evidence; independent of authentication risk |
| Recurring reward | Window-based entitlement with explicit selection and claim policies |
| Penalty / correction | Authorized disciplinary consequence / correction of an invalid prior effect; separate reasons and compensation policies |
| Restriction | Scoped action limitation with authority, timing, revision, and enforcement state |
| Score / rank | Competition-specific performance / relative standing; neither is XP or an access role |
| League / division | Competitive grouping, not a platform role or a customer subscription tier |
| Virtual currency | Explicitly identified spendable unit governed by Virtual Economy |
| Points / stars | Display labels; classify explicitly as advancement, score, recognition, or currency |
| Skill / mastery | Gamified progression; actual competencies and credentials remain with their external authorities |
| Event | Qualify as integration event, gamification event/run, or scheduled gathering |
| Clan / collaboration | Game-specific Play Group or cooperative mission; general communities and business collaboration remain external |

Multiple virtual currencies are a first-class capability:

- Identify a currency by tenant-scoped immutable ID with a tenant-unique code, precision, lifecycle, and versioned economic policy. Names such as gems, coins, and stars are presentation metadata, not interchangeable units.
- Identify a wallet account by tenant, economy scope, participant, and currency ID. Economy scope determines whether a balance is isolated to one program or explicitly shared by named programs within the tenant.
- Maintain independent balances and policies for issuance, spending, transfers, holds, expiry, caps, balance limits, and overdrafts. Never sum or substitute different currencies implicitly.
- Use exact amount arithmetic and immutable, traceable ledger movements. Available balances account for holds; refunds and corrections append compensating movements.
- Currency exchange requires an explicit pair policy and recorded quote/rate, rounding, fees, limits, and coordinated debit/credit outcome. Exchange is not implied by supporting multiple currencies.
- Multi-currency prices identify every required amount. Rewards coordinates redemption, reservations, capture/release, and fulfillment acknowledgment with Virtual Economy and any external benefit owner.
- Reputation cannot be purchased, transferred, spent, or booster-amplified by default. XP and levels remain distinct from reputation and all currencies.

### Trust, Integrity, and Security Risk

- Reputation owns community/business `TrustDimension`, `TrustPolicy`, `TrustAssessment`, and `EvidenceConfidence`. A trust assessment specializes a reputation assessment, with explicit subject, scope, dimension, standing, confidence, evidence, policy version, and assessment time.
- Unknown or insufficient evidence is distinct from low trust. Composite trust factors require explicit weights and missing-evidence rules. Check-ins, purchases, XP, levels, and boosters do not automatically confer trust.
- Integrity & Sanctions owns gamification manipulation evidence, violation cases, sanctions, and appeals. A signal or low standing is not automatically a proven violation; any consequence requires an authorized policy decision.
- Identity & Access or an external security-risk authority owns account-compromise/authentication risk. Neither reputation nor gamification integrity can silently become platform access policy.

### Recurring and Dynamic Rewards

Recurring Reward Programs span existing contexts; they do not introduce another bounded context.

| Responsibility and concepts | Owner |
| --- | --- |
| `RecurringRewardProgram`, audience, enrollment, lifecycle, policy applicability | Programs & Participation |
| `CheckIn`, activity qualification, recurring missions/runs and their activity windows | Missions |
| Consecutive attendance, streak freezes, milestones | Progression |
| Reward-side `RecurrencePolicy`, `RewardWindow`, `RewardSchedule`, `RewardTable`, `RewardSelectionPolicy`, `CatchUpPolicy` | Rewards & Inventory |
| `ClaimEntitlement`, `ClaimRecord`, selection snapshot, automatic grant or claim, fulfillment | Rewards & Inventory |
| Multiple currency movements | Virtual Economy |

- Support calendar daily/weekly/monthly/custom schedules, rolling cooldowns, sequential cycles, enrollment-anchored schedules, and streak/cohort-based reward selection under explicit policies.
- Distinguish qualifying check-ins, automatic recurring entitlements, recurring mission completion, and streak milestones. A weekly membership gift does not need a synthetic mission.
- Resolve stable windows using authoritative server evaluation, validated activity times, a declared anchor/time zone/week start, half-open boundaries, daylight-saving rules, and late-arrival policy. Switching zones cannot open duplicate entitlements.
- Define missed-window reset/skip/pause/grace/freeze/catch-up behavior. Missed attendance is not an implicit disciplinary penalty or reputation loss.
- Select fixed, chosen, or weighted reward bundles at a declared stage and persist the selection/policy snapshot; retries cannot reroll. Bundles may contain multiple currencies and items.
- Enforce one entitlement per `(tenant, program, reward plan, participant, window, reward slot)` and atomic claims. A policy version change cannot create another claim for the same slot.
- Rewards owns claim windows; Missions owns qualification windows. Aligned plans reference the authoritative mission window. Restrictions define whether earning/claims are deferred, forfeited, or catch-up eligible, including in-flight fulfillment recovery.

### Penalties and Temporary Access Limitations

Integrity & Sanctions owns the authority, reason, scope, policy, evidence, decision revision, appeal, and requested effects of a gamification sanction. It tracks per-target enforcement acknowledgments. The resource/action owner applies and enforces each effect under its own invariants.

| Penalty or limitation | Applying/enforcing owner |
| --- | --- |
| XP deduction / level recalculation | Progression |
| Qualified reputation reassessment / authorized adjustment | Reputation; prevent circular punishment and double-counting evidence |
| Score deduction / competition disqualification / placement correction | Competition |
| Badge/title revocation | Achievements |
| Currency forfeiture / transfer or spending restriction | Virtual Economy; preserve ledger, hold, balance-floor, and overdraft rules |
| Item/booster revocation / claim, gifting, or redemption restriction | Rewards & Inventory |
| Enrollment, mission, or group participation restriction | Programs & Participation, Missions, or Play Groups according to target scope |
| Booking/publishing/other business capability restriction | The business context owning that capability, under explicit authority |
| Authentication/session/account restriction | Identity & Access or designated access-policy authority; gamification requests are not direct enforcement |

- Distinguish penalties from corrections, decay, expiry, cooldowns, and unmet eligibility. Each consequence records decision/effect IDs, provenance, and restoration/compensation policy. No implicit real-money charge or bypass of ledger invariants is permitted.
- A restriction names subject, tenant/program, resource, actions, issuer authority, start/end or review condition, policy version, reason, and decision revision. Temporary restrictions require a finite end or defined review deadline; avoid a global User `is_banned` flag.
- Evaluate time-bounded effectiveness as `startsAt <= now < endsAt` together with decision status. Expiry must not depend solely on a scheduled event arriving. Pending enforcement is distinct from an applied restriction.
- Overlapping restrictions compose explicitly. Lifting one cannot lift another; stale delivery cannot reinstate a revoked/newer decision. Appeals and overturned decisions trigger explicit owner-applied restoration/compensation.
- The action owner enforces restrictions at action acceptance, with declared policy freshness, invalidation, maximum tolerated delay, and behavior when policy state is unavailable. Existing sessions/tokens do not automatically bypass newly effective restrictions.
- A gamification outage does not create a universal business lockout, but neither can ordinary failure isolation bypass an independently authorized business/security restriction. External access requests require acceptance and application acknowledgments from the authoritative owner.

### Cross-Module Responsibilities

| Module or domain | Relationship to Gamification |
| --- | --- |
| `zhinux-user` | Owns user registry, profile attributes, and user lifecycle; profiles may display composed gamification summaries |
| `zhinux-identity` | Owns credentials, authentication, account/security access policy; accepts authorized restriction requests and reports enforcement; reputation is not authentication risk |
| `zhinux-calendar` | Owns reservations, conflicts, booking facts, and enforcement of booking-specific limitations; scheduled gatherings stay with Calendar/Booking |
| `zhinux-tenant` | Intended tenant authority; detailed ownership/contract still requires definition |
| `zhinux-asset` | Intended media boundary for badge artwork and reward imagery; gamification owns award meaning and asset references |
| `zhinux-contracts` | Owns API/event schema location, not gamification business policy or shared aggregates |
| `zhinux-platform` / `zhinux-kv` | Technical utilities / intended storage capability; neither becomes owner of progress, reputation, or balances |
| Learning/Skills, Community/Organization, Commerce/Payments, Fulfillment | External domain boundaries for real competencies, general groups, money, and actual benefits; not new modules established by this map |
| Notifications / Analytics | External consumers for delivery and analysis; those capabilities are not assigned to an existing placeholder module here |

### Integration, Corrections, and Lifecycle

- Business domains publish facts; gamification evaluates versioned earning, objective, reputation, and scoring policies. Source domains do not need to calculate gamification rewards.
- Inputs retain source event ID, tenant/program scope, subject, occurrence time, schema version, and causation. Outcomes retain applied policy version and source evidence.
- Event deduplication is scoped to source, rule/version, recipient, and outcome. Stable business uniqueness additionally protects recurring entitlements, claims, sanction effects, and restrictions across rule-version changes. Duplicate delivery, out-of-order activity, and replay must not duplicate awards, currency movements, gifts, or penalties.
- Definition changes have effective dates and explicit retroactivity rules. Rebuilding projections is distinct from granting new outcomes.
- Each context defines reversal/compensation semantics, including invalidated reputation evidence, spent/expired rewards, and corrected competition results.
- Define opt-out, suspension, deletion, retention, leaderboard visibility, roster changes, earning caps, cooldowns, disputes, and manual-adjustment audit reasons.
- A gamification failure must not invalidate an otherwise valid source-domain action; independently authorized business/security restrictions still apply under the action owner's declared enforcement policy. Cross-context fulfillment and sanctions track durable intent, per-target acknowledgment, and recovery rather than assuming atomic global completion.
- No context reads another's tables or imports another's internal model. Cross-context concepts are mapped through published contracts.

The existing Lab 4 flow and its event deferral remain unchanged. These planned contexts do not introduce gamification into that lab's mandatory request path.

## Lab 4 Simplification

The Lab 4 specification names two contexts:

- `identity` for users and tenants.
- `booking` for reservations and conflicts.

Zhinux's intended long-term architecture is more precise:

- `zhinux-user` owns user registry and profile concerns.
- `zhinux-identity` owns authentication and access concerns.
- `zhinux-calendar` owns booking and reservation concerns.

To preserve Lab 4's two-service scope, its simplified `identity` role maps to `zhinux-user`. The Lab 4 runtime is therefore:

- User context: `zhinux-user`.
- Booking context: `zhinux-calendar`.

`zhinux-identity` is explicitly out of scope for this lab. It should not be added merely to satisfy the word “identity” in the lab brief. Authentication, passwords, sessions, tokens, and authorization are separate future capabilities.

## Context Map

```mermaid
flowchart LR
    Client[Client or test harness]
    User[User Context<br/>zhinux-user]
    Booking[Booking Context<br/>zhinux-calendar]
    UserDB[(User-owned storage)]
    BookingDB[(Booking-owned storage)]
    Identity[Identity & Access Context<br/>zhinux-identity<br/>deferred]

    Client -->|CreateUser| User
    Client -->|CreateReservation| Booking
    Booking -->|GetUser / existence check<br/>synchronous gRPC| User
    User --> UserDB
    Booking --> BookingDB
    Identity -. future authentication boundary .-> User

    Booking -. forbidden .-> UserDB
```

## Context Ownership

### User Context

Repository: `zhinux-user`

Owns:

- User identity within the product's user registry.
- User lifecycle and existence.
- Profile attributes such as phone, name, username, and email.
- Uniqueness rules for user-owned identifiers.
- User persistence schema.
- Public User gRPC behavior.

Does not own:

- Password verification, login sessions, or token issuance.
- Reservation eligibility rules beyond exposing authoritative user state.
- Venues, schedules, or reservation conflicts.

### Booking Context

Repository: `zhinux-calendar`

Owns:

- Reservations.
- Venue identifiers as understood by Booking.
- Time ranges and slot invariants.
- Conflict detection.
- Reservation idempotency behavior.
- Booking persistence schema.
- Public Booking gRPC behavior.

Does not own:

- User profiles or credentials.
- Authentication or token issuance.
- User persistence.
- The meaning of User fields beyond the minimum Booking eligibility contract.

### Identity & Access Context

Repository: `zhinux-identity`

Long-term ownership:

- Credentials and authentication.
- Login and logout.
- Access and refresh tokens.
- Account authentication state and security policy.

Lab 4 status: deferred and not part of the create-user → create-reservation flow.

## Ubiquitous Language

| Term | Owning context | Meaning |
| --- | --- | --- |
| User | User | A registered product user with a stable `UserID` |
| UserID | User; referenced by Booking | An opaque identifier issued by User |
| Reservation | Booking | A request accepted for one user, venue, and slot |
| VenueID | Booking | The Booking identifier of a reservable venue |
| Slot | Booking | A venue-specific half-open time interval |
| Conflict | Booking | An overlap violating Booking rules |
| Identity | Identity & Access | Authentication and credential state, not a profile synonym |
| Principal | Identity & Access | An authenticated actor represented by credentials |

Booking may reference a `UserID`, but that does not transfer ownership of the User concept to Booking.

## Integration Contract

### Lab 4 Synchronous Flow

1. A client calls User to create a user.
2. User validates its invariants and stores the user.
3. A client calls Booking to create a reservation with that `UserID`.
4. Booking calls User through a generated gRPC client to verify existence.
5. Booking loads existing reservations from its own repository.
6. Booking applies reservation and conflict rules.
7. Booking stores the accepted reservation in its own repository.

The decision and trade-offs are recorded in `docs/adr/0001-booking-user-validation.md`.

### Contract Ownership

Cross-service API and event schemas live in `zhinux-contracts`.

Rules:

- Services import generated contract packages, never another service's internal packages.
- Proto messages are transport contracts, not shared domain models.
- Each gRPC adapter maps proto messages to local application or domain types.
- Breaking contract changes require a new version.
- Events are deferred for the Lab 4 mandatory path.

## Allowed Dependencies

Booking may depend on:

- Generated `user.v1` contract code.
- A local `UserExistenceChecker` or equivalent outbound port.
- A gRPC adapter implementing that port.
- Shared technical utilities from `zhinux-platform` when they do not contain business concepts.

User may depend on:

- Generated `user.v1` contract code.
- Its own local domain, application, ports, and adapters.
- Shared technical utilities from `zhinux-platform`.

## Forbidden Dependencies

The following are architectural violations:

- Booking reading or writing User tables.
- User reading or writing Booking tables.
- Importing `zhinux-user/internal/...` from Booking.
- Importing `zhinux-calendar/internal/...` from User.
- Sharing ORM entities or persistence models.
- Placing User and Reservation aggregates in a shared library.
- Using `zhinux-contracts` as a home for business logic.
- Adding `zhinux-identity` to the Lab 4 request path without a distinct authentication requirement.

## Consistency Model

Lab 4 uses synchronous validation:

- User existence is strongly checked at reservation request time.
- Booking fails closed when User cannot be reached.
- Booking owns the final conflict and acceptance decision.
- Booking stores only the opaque `UserID`; it does not cache the User profile.

Later event-driven projections will be eventually consistent and require explicit policies for lag, replay, deletion, and suspension.

## Code-Level Enforcement

Each service should maintain:

- A domain package with no gRPC, database, or message-broker imports.
- An application service that depends on local ports.
- A gRPC adapter responsible for proto mapping.
- A repository adapter owned by that service.
- Tests that use fakes at port boundaries.

Recommended Booking port:

```go
type UserExistenceChecker interface {
    Exists(ctx context.Context, userID string) (bool, error)
}
```

The exact name may change, but the dependency direction must remain Booking application → Booking-owned port ← User gRPC adapter.

## Lab 4 Proof Checklist

- [ ] User and Booking run as separate processes.
- [ ] Create user → create reservation succeeds.
- [ ] An unknown user cannot create a reservation.
- [ ] Booking never accesses User storage.
- [ ] Neither service imports the other's internal packages.
- [ ] Unit tests prove domain and application behavior.
- [ ] An integration test proves the gRPC boundary.
- [ ] Service boundary docs remain synchronized with this document.

## Future Evolution

Labs 5–7 may add:

- `UserCreated` and user lifecycle events.
- A Booking-owned user eligibility projection.
- NATS and JetStream delivery.
- Retry, dead-letter, outbox, and idempotent-consumer behavior.

Those capabilities should extend this boundary rather than weakening service ownership.
