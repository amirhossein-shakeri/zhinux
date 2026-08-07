# ADR 0001: Validate Booking Users with Synchronous gRPC

- Status: Accepted
- Date: 2026-08-03
- Decision owners: User and Booking contexts
- Applies to: Lab 4 thin slice

## Context

The Lab 4 end-to-end flow is:

1. Create a user.
2. Create a reservation for that user.

The Booking context must reject reservations for unknown users without reading another service's database or importing another context's domain packages.

The long-term Zhinux model distinguishes:

- User: profile and user-registry lifecycle.
- Identity & Access: credentials, authentication, account access, and tokens.
- Booking: reservations, venues, slots, and conflict decisions.

Lab 4 intentionally limits the system to two running services. For this lab, the specification's simplified `identity (users/tenants)` context is implemented by `zhinux-user`. `zhinux-identity` remains outside the runtime flow and is reserved for authentication and credential concerns in later work.

## Decision

During reservation creation, `zhinux-calendar` synchronously calls `zhinux-user` over gRPC to verify that the supplied user exists.

The initial implementation should reuse the smallest stable user query contract that proves existence. Booking translates the response into its own local concept and stores only the user's identifier.

Booking must not:

- Read the User database directly.
- Import `zhinux-user/internal/...`.
- Persist a copied User aggregate.
- Decide whether a user profile is valid beyond the response required for booking eligibility.

User remains the source of truth for user existence. Booking remains the source of truth for reservations and conflicts.

## Why Synchronous gRPC

Synchronous validation is selected because it provides the highest learning and delivery value for Lab 4:

- It directly demonstrates a contract-protected bounded-context boundary.
- It produces an immediate, deterministic result for `CreateReservation`.
- It requires no projection lag, event broker, replay strategy, or consumer recovery.
- It keeps the lab within its two-service and 2–6 hour intent.
- It reuses the contract-first gRPC skills from Lab 2.

## Alternatives Considered

### Booking Reads the User Database

Rejected. This couples Booking to User storage and schema decisions, bypasses User business rules, and prevents independent evolution.

### Booking Imports the User Domain Package

Rejected. A Go import would create compile-time coupling between bounded contexts and expose internal domain concepts as shared models.

### `UserCreated` Event Projection

Deferred. Booking could consume user lifecycle events and maintain a local eligibility projection, removing the synchronous runtime dependency. That approach introduces eventual consistency, broker operations, replay, duplicate handling, and projection recovery. Those concerns belong to Labs 5–7.

### Call `zhinux-identity`

Rejected for this lab. Authentication status and credentials are not required to prove the basic create-user → create-reservation flow. Calling both User and Identity would create a third service and blur the lab's simplified terminology.

## Failure Semantics

The Booking application service should distinguish:

- User found: continue reservation validation.
- User not found: reject with a domain/application error mapped to gRPC `NotFound` or `FailedPrecondition`.
- User service unavailable or deadline exceeded: fail closed and return `Unavailable` or `DeadlineExceeded`.
- Booking conflict: reject independently of user validation with the Booking conflict reason.

The gRPC call must use the incoming context and a bounded deadline. Retry policy is not part of the first Lab 4 slice.

## Consequences

### Positive

- Boundaries are visible in code through an outbound Booking port and a gRPC adapter.
- Each service owns its data and domain model.
- The end-to-end flow is easy to test.
- The implementation stays small enough to finish with quality.

### Negative

- Reservation creation depends on User availability.
- Every new reservation adds a network call.
- User existence is checked at request time only; later deletion or suspension requires an explicit policy.

## Evolution Path

In Lab 5 or later:

1. Publish versioned user lifecycle events.
2. Build a local Booking projection containing only booking-relevant user eligibility.
3. Define projection lag and rebuild behavior.
4. Decide whether gRPC remains a fallback or is removed.

This evolution must be recorded in a new ADR rather than silently changing this decision.

## Verification

The decision is satisfied when:

- Creating a known user and then a reservation succeeds.
- Reserving for an unknown user fails.
- Booking tests use a fake user-existence port without importing User internals.
- An integration test crosses the gRPC boundary.
- Repository search finds no Booking dependency on User persistence or internal domain packages.
