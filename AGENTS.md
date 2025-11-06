AGENTS.md — EmergentFieldAnalysis

\#\# Purpose  
This document defines the agent roles involved in the Emergent Field Analysis Control Center. Each agent operates on discrete responsibilities to maintain clean boundaries, avoid code bloat, and ensure safe partial automation through Codex.

\---

\#\# Agents

\#\#\# 1\) Deterministic Metrics Agent (DMA)  
\- Extracts numeric statistics from raw Julia arrays.  
\- Computes min, max, mean, std, skew, kurtosis, percentiles.  
\- Computes morphology approximations (peak count, cluster count, edge density).  
\- Must be fast, multi-threaded, allocation minimal.  
\- Never calls LLM.

\#\#\# 2\) Routing Agent (RA)  
\- Decides if a run can be handled deterministically or requires LLM review.  
\- Applies rule-based thresholds from config \+ LLM learned overrides.  
\- Default conservative routing (prefer deterministic).  
\- Never modifies engine parameters.

\#\#\# 3\) LLM Review Agent (LLR)  
\- Communicates using JSON Contract Spec v1.0.  
\- Sends summaries not arrays.  
\- Receives suggestions, flags, overrides.  
\- Does not execute or mutate simulation state directly.

\#\#\# 4\) QC Sampling Agent (QCSA)  
\- Selects 5% sample regions by default.  
\- Strategy can be overridden by LLM.  
\- May escalate to time-series request if flagged.

\#\#\# 5\) Archival Agent (AA)  
\- Writes JSONL log for every run.  
\- Stores routing decisions, version stamps, metrics, LLM responses.  
\- Maintains reproducibility and audit trail.

\---

\#\# Invariants  
\- Deterministic agents never depend on LLM.  
\- LLM is advisory, not authoritative.  
\- Arrays never leave Julia memory (LLM sees summaries only).  
\- All decisions must be reproducible and logged.

\---

\#\# Execution Order  
1\) Deterministic Metrics Agent runs first  
2\) Routing Agent decides path  
3\) QC Sampling Agent applies sampling policies  
4\) LLM Review Agent runs if required or QC selected  
5\) Archival Agent stores results final

