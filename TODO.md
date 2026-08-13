# TODO: Camera Effort Calculation Logic

## Architecture Decisions

- **Grain**: The `calculate_cameras_summary()` pipeline will be replaced with the `compute_daily_status()` → `compute_daily_summary()` pipeline, producing **daily** output. CLI changes deferred to a later step.
- **Approach**: Period-by-period filling. For each camera ID, iterate its field checks in date order; each pair of consecutive checks (e.g. `A → D`) defines a period, and the days of that period are filled according to the transition's fill rule (see *Period Fill Rules*). This replaces the previous top-down post-hoc correction via `apply_camera_status_rules()`.
- **Midpoint scope**: The "photos, no date" sub-case (A → D criterion #2) computes the midpoint **per period** — over the interval between the two review dates of that transition — not over the camera's whole observed span.
- **Pessimistic default**: When activity dates are unknown, underestimate effort — prefer "not working" over "working". For the "photos, no date" sub-case this means filling `floor(N/2)` active days (not `ceil(N/2)`).
- **Fill direction (mixed convention)**: `R` is an event — the camera is retired on the check day, so `R` applies from that day forward ("opens"). `A` and `D` are observations of how the camera was found at the check, i.e. the state the preceding period ended in ("ends"). The days between two checks are filled by the transition's rule.
- **Status grid semantics**: The daily status grid reflects what happened in each period. `compute_daily_summary()` filters on `camera_status == "A"` and counts effort as `n_distinct(ID)` — this is correct; the period fill rules shape the grid, not the summary aggregation.

## Period Fill Rules

For each camera, sort its field checks by date. Each consecutive pair defines a period; fill its days as follows:

| Transition | Fill rule |
|-----------|-----------|
| A → A | All days = A |
| A → D | A → D criterion (see below) |
| A → R | A → D criterion for the days before retirement; the retirement day = R |
| D → A | All days = A (the camera was actually working) |
| D → D | A → D criterion |
| D → R | A → D criterion for the days before retirement; the retirement day = R |
| R → A | R up to the A check, then A |
| R → R | Open — see Open Questions |

**Legend:** A = Active, R = Retired, D = Down/Not working

Longer chains (3+ checks) compose the rules above period by period.

`R` is an event (retirement happens on the check day), so it "opens" the `R` stretch and holds forward until the next check. `A` and `D` are observations of how the camera was found, so they describe how the period since the previous check "ends"; the A → D criterion resolves when the flip to `D` happened.

### Special Criterion: A → D

1. If a photo capture date exists: fill A up to that date (last evidence the camera was operating), then D. Tested with `CT-01-ad1-CT`.
2. If no photo capture date but captured photos exist: fill A for the first `floor(N/2)` days of the period and the rest as not active (pessimistic — underestimate effort when the activity date is unknown). For A → R / D → R, the retirement day is filled R instead of D. Tested with `CT-01-ad2-CT` and `CT-01-www-CT`.
3. If no photo capture date and no captured photos: fill all days = D (do not count effort). Tested with `CT-01-ad3-CT`.

---

## Test Cases

| Test Case | Transition | Sub-case | Expected Status | Status |
|-----------|-----------|----------|-----------------|:---:|
| CT-01-yyy-CT | A → A | — | All A | ✅ |
| CT-01-zzz-CT* | A → A (photo=review date) | — | All A | ✅ |
| CT-01-www-CT | A → R | 2 (photos, no date) | A,A,D,D,R | ✅ |
| CT-01-xxx-CT | R → A → A | — | R,R,A…A | ✅ |
| CT-01-ad1-CT | A → D | 1 (has photo date) | A,A,A,D,D | ✅ |
| CT-01-ad2-CT | A → D | 2 (photos, no date) | A,A,A,D,D,D | ✅ |
| CT-01-ad3-CT | A → D | 3 (no photos) | D,D,D | ✅ |
| CT-01-da1-CT | D → A | — | All A | ✅ |
| CT-01-dd1-CT | D → D | 1 (has photo date) | A,A,D,D | ✅ |
| CT-01-dr1-CT | D → R | 1 (has photo date) | A,A,D,R | ✅ |
| CT-01-rad-CT | R → A → D | 2 (photos, no date) | R,R,A,A,D,D,D | ✅ |
| CT-01-dad-CT | D → A → D | 1 (has photo date) | A,A,A,A,A,A,D | ✅ |

\* CT-01-zzz-CT: photo capture date matches the field review date.

Notes:

- the pessimistic per-period midpoint over the A → D period (5 days → `floor(5/2)` = 2 A + 3 D) reproduces the current behavior.
- All other cases are unchanged by the per-period midpoint, the pessimistic default, and the mixed convention.

---

## Remaining Multi-Transition Patterns

Each pattern below needs test data, a test assertion, and fill-rule coverage. At least one sub-case per pattern must be covered.

- [ ] R → A → D, sub-case 1 (has photo date)
- [ ] R → A → D, sub-case 3 (no photos)
- [ ] D → A → D, sub-case 2 (photos, no date)
- [ ] D → A → D, sub-case 3 (no photos)
- [ ] A → D → A (active, deactivated, reactivated)
- [ ] R → A → R (retired, reactivated, retired again)
- [ ] A → R → A (active, retired, reactivated)
- [ ] D → R → A (deactivated, retired, reactivated)
- [ ] Any longer chain (4+ records)

---

## Things to Consider for Data Predating the Existence of "R"

- Default to a pessimistic scenario (count less effort rather than more).
- If captured photos exist, we know the camera worked. Example: if the camera was reviewed on August 2 with status D, the previous review date was June 1, and the memory-card review shows captured photos, we know the camera was operating in the field — apply the A → D criterion.
- If no captured photos exist, do not count effort.

---

## How Do We Handle Photo Capture Dates That Are Out of Range?

- [ ] Raise an error.
- [ ] Consider: if a row in `cameras_daily_status` has NAs in both `Revision` and `camera_status`, this may indicate a date was entered incorrectly.
- [ ] Treat this as evidence that something is wrong with the data (e.g., a misconfigured date).

---

## Open Questions

- [ ] Should R → R cases raise an error instead of silently not counting toward effort?
- [ ] How should we treat rows with Estado_camara == NA or Fecha_revision_campo == NA?
- [ ] Are we counting all the records with Fecha_captura_foto on the same period? Eg, CT-01-double-captura-CT has Fecha_revision_campo = 2024-01-02 and 2024-01-09, with Fecha_captura_foto = 2022-01-03 and 2022-01-05. 
