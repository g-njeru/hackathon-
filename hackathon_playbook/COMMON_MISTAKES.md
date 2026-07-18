# Common Mistakes to Avoid

Anti-patterns that waste time, kill momentum, and lose hackathons.

---

## Infrastructure Mistakes

### Building microservices for a hackathon

**Why it's bad**: Integration overhead, network debugging, deployment complexity.

**Do this instead**: The Deceptive Monolith — one codebase, one deployment. Split after the hackathon if needed.

### Skipping deployment on day 1

**Why it's bad**: You don't know if it works in production until it's too late.

**Do this instead**: Deploy "Hello World" on day 1. Every commit after that should produce a deployable artifact.

### Custom auth instead of Supabase/Firebase

**Why it's bad**: Auth is hard. JWT edge cases, password reset, OAuth flows — this eats hours.

**Do this instead**: Use Supabase Auth. 15 minutes to set up, handles email, OAuth, magic links, and row-level security.

### Self-hosting everything

**Why it's bad**: You spend the hackathon fighting infrastructure, not building features.

**Do this instead**: Use managed services. Supabase for DB+auth, Vercel/Railway for deploy, Redis Cloud for caching.

---

## Development Mistakes

### No data contract

**Why it's bad**: Frontend and backend build different shapes. Integration day is a nightmare.

**Do this instead**: Define the JSON schema in the first 15 minutes. Everyone builds against the same contract.

### Building UI before mocking data

**Why it's bad**: You're blocked waiting for the backend to return real data.

**Do this instead**: Build the UI against hardcoded JSON. Swap for real API later.

### Perfect test coverage

**Why it's bad**: You spend more time writing tests than building features.

**Do this instead**: One E2E test for the demo path. Integration tests for critical business logic. Skip everything else.

### Over-engineering error handling

**Why it's bad**: Edge cases you'll never demo steal hours from core features.

**Do this instead**: Catch errors, display a message, move on. Perfect error handling is for post-hackathon.

### Long-lived feature branches

**Why it's bad**: Merge conflicts pile up. Nobody knows what's working.

**Do this instead**: Merge to `main` every 2 hours. Small merges, easy to debug.

---

## Team Mistakes

### No pair programming

**Why it's bad**: Knowledge silos. If one person gets stuck, nobody can help.

**Do this instead**: Pair for the first hour. Re-pair during the final 2 hours for demo prep.

### Not cutting scope

**Why it's bad**: You end up with 5 half-built features instead of 1 working one.

**Do this instead**: Pick the one feature that proves your idea. Build that. Everything else is bonus.

### No demo backup

**Why it's bad**: Live demos fail. If you have no backup, you have no demo.

**Do this instead**: Record a video of the demo flow. Take screenshots. Have both ready before demo day.

### Working in silence

**Why it's bad**: Teammates don't know what you're building. Integration surprises.

**Do this instead**: 5-minute standup every 2 hours. "What I did, what I'm doing, what's blocking me."

---

## Presentation Mistakes

### Showing the code

**Why it's bad**: Judges care about the product, not your architecture.

**Do this instead**: Show the user experience. If they ask about tech, explain it briefly.

### Too much setup

**Why it's bad**: Judges lose attention. By the time you get to the demo, they've checked out.

**Do this instead**: Problem → Solution → Demo. Get to the demo in under 2 minutes.

### Apologizing

**Why it's bad**: It highlights what you didn't build instead of what you did.

**Do this instead**: Say "next, we'd build..." instead of "we didn't have time to..."

### Running over time

**Why it's bad**: Organizers cut you off. Judges don't see the full demo.

**Do this instead**: Rehearse. Time yourself. If it's over 5 minutes, cut something.

---

## The "Anchor" Rule

If something is taking too long and it's not the core value proposition:

> **Delete it and move on.** You can always say "we planned to build X" in the presentation.

The judges care about what works, not what you intended to build.
