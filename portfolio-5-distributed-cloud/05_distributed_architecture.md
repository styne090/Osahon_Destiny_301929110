# Distributed & Cloud Database Strategy

## Sharding Strategy
* **Sharding Key:** `customer_id`
* **Justification:** Distributes transaction and account data across physical database nodes while ensuring all data for a specific customer stays on the same shard, avoiding expensive cross-shard joins.

## CAP Theorem Positioning
* **Core Ledger (CP):** Prioritizes Consistency and Partition Tolerance to guarantee absolute precision in balances and eliminate double-spending risks.
* **Analytics & Telemetry (AP):** Employs Eventual Consistency for log streaming to achieve ultra-low write latency across regions.