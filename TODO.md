# TODO: Camera Effort Calculation Logic

## Architecture Decisions

- **Grain**: The `calculate_cameras_summary()` pipeline will be replaced with the `compute_daily_status()` → `compute_daily_summary()` pipeline, producing **daily** output. CLI changes deferred to a later step.
- **Approach**: Top-down post-hoc correction via `apply_camera_status_rules()` (extend the current pattern rather than iterate period-by-period).
- **Status grid semantics**: The daily status grid reflects what happened in each period. `compute_daily_summary()` filters on `camera_status == "A"` and counts effort as `n_distinct(ID)` — this is correct; the case-table rules shape the grid, not the summary aggregation.

## Case Table: Single Transitions (already implemented and tested)

| Test Case | Transition | Expected Status | Status |
|-----------|-----------|-----------------|:---:|
| CT-01-yyy-CT | A → A | All A | ✅ |
| CT-01-zzz-CT* | A → A (photo=review date) | All A | ✅ |
| CT-01-www-CT | A → R | Uses A → D criterion | ✅ |
| CT-01-xxx-CT | R → A → A | R for R→A period, A for A→A period | ✅ |
| CT-01-ad1-CT | A → D (has photo date) | A up to last photo date, then D | ✅ |
| CT-01-ad2-CT | A → D (photos, no date) | A up to midpoint, then D | ✅ |
| CT-01-ad3-CT | A → D (no photos) | All D | ✅ |
| CT-01-da1-CT | D → A | All A | ✅ |
| CT-01-dd1-CT | D → D | Uses A → D criterion | ✅ |
| CT-01-dr1-CT | D → R | Uses A → D criterion | ✅ |

\* CT-01-zzz-CT: photo capture date matches the field review date.

**Legend:** A = Active, R = Retired, D = Down/Not working

### Special Criterion: A → D

1. If a photo capture date exists: fill up to that date (last evidence the camera was operating). Tested with `CT-01-ad1-CT`.
2. If no photo capture date but captured photos exist: count effort as half the time between the two dates. Tested with `CT-01-ad2-CT` and `CT-01-www-CT`.
3. If no photo capture date and no captured photos: fill with D (do not count effort). Tested with `CT-01-ad3-CT`.

---

## To Do: Multi-Transition Cases

Implement `compute_daily_status()` and extend `apply_camera_status_rules()` for cameras with **three or more field-check records** (two or more transitions). Candidates include:

- [ ] R → A → D  (retired, reactivated, then deactivated)
- [ ] D → A → D  (deactivated, reactivated, deactivated again)
- [ ] A → D → A  (active, deactivated, reactivated)
- [ ] R → A → R  (retired, reactivated, retired again)
- [ ] A → R → A  (active, retired, reactivated)
- [ ] D → R → A  (deactivated, retired, reactivated)
- [ ] Any longer chain (4+ records)

Each multi-transition case needs:
1. Test data in `camaras_campo.csv` and `camaras_memoria.csv`
2. A test assertion in `test_process_cameras_data.R`
3. Rule logic in `apply_camera_status_rules()` (and supporting classification functions)

---

## Things to Consider for Data Predating the Existence of "R"

- Default to a pessimistic scenario (count less effort rather than more).
- If captured photos exist, we know the camera worked. Example: if the camera was reviewed on August 2 with status D, the previous review date was June 1, and the memory-card review shows captured photos, we know the camera was operating in the field — apply the A → D criterion.
- If no captured photos exist, do not count effort.

---

## How Do We Handle Photo Capture Dates That Are Out of Range?

- Raise an error.
- Consider: if a row in `cameras_daily_status` has NAs in both `Revision` and `camera_status`, this may indicate a date was entered incorrectly.
- Treat this as evidence that something is wrong with the data (e.g., a misconfigured date).

---

## Open Questions

- Should R → R cases raise an error instead of silently not counting toward effort?
