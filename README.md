# My-demo-project
Readme file
This is my first change in my local repo!

## Alerts at Geofence report — Playwright E2E suite

`tests/` is a Playwright project covering the 12 Zephyr UI test cases originally
written for a "Smart Geofence Alert Health Report" (Jira Epic
[FS-1692](https://safefleet.atlassian.net/browse/FS-1692)). The specs were
**rewritten once against px-web-app's actual implementation** — checked out
from branch `20260612-110957-smart-geofence-alert` — which turned out to
differ substantially from the original test-plan description. See the
per-ticket "QA note" comments on FS-1972–FS-1977 and FS-2006–FS-2011 for the
full mismatch write-up; the short version:

- The real feature is called **"Alerts at Geofence"**, a filter-driven report
  inside the existing Reports module (`/reports/alerts-at-geofence`) — not a
  dedicated per-location page. Nothing loads until you pick **Target
  (Assets/Asset Groups) + Geofence(s) + Date Range** and click **Generate**.
- "Expanding a row" doesn't exist — clicking a nonzero Arrival/Departure Alert
  Count cell **navigates to a separate detail page**
  (`/reports/alerts-at-geofence-detail`) via Angular Router state, so it can't
  be deep-linked directly in a test.
- Access is gated by a **global feature toggle** (`alertsAtGeofenceReportEnabled`),
  not a per-user permission.
- Two scenarios (unresolved-alert row styling, open/incomplete-crossing
  treatment) are **confirmed implementation gaps** — the code path
  (`classToApply`) exists but is never populated. Their specs are marked
  `test.fixme()` rather than deleted, so the gap stays visible in the suite
  until a dev fixes it.

| Spec | Zephyr key | Scenario | Status |
|---|---|---|---|
| TC-SGA-001 | FS-1972 | Report lists crossings with arrival/departure alert counts | ✅ |
| TC-SGA-002 | FS-1973 | Alert count cell navigates to the detail drill-down | ✅ |
| TC-SGA-003 | FS-1974 | Unresolved departure alerts visually distinguished | 🔧 `fixme` — gap |
| TC-SGA-004 | FS-1975 | Date-range preset restricts crossings | ✅ |
| TC-SGA-005 | FS-1976 | Open crossing renders non-interactive zero departure count | ✅ (badge half is `fixme`) |
| TC-SGA-006 | FS-1977 | Recently departed unresolved crossing appears promptly | ✅ (identify-at-a-glance half is `fixme`) |
| TC-SGA-007 | FS-2006 | Report gated by the feature toggle (not per-user permission) | ✅ |
| TC-SGA-008 | FS-2007 | "No data found" message for a zero-result report | ✅ |
| TC-SGA-009 | FS-2008 | "No alert details to show." for a zero-alert crossing | ✅ |
| TC-SGA-010 | FS-2009 | Error message on API failure | ✅ (loading-indicator half is `fixme`) |
| TC-SGA-011 | FS-2010 | Invalid custom date range blocked | 🔧 `fixme` — calendar day-picking not yet automated |
| TC-SGA-012 | FS-2011 | Pagination for a filter combination with many crossings | ✅ |

### Setup

```bash
cd tests
npm install
npx playwright install
cp .env.example .env   # fill in E2E_BASE_URL, credentials, and test data keys
```

### Run

```bash
npm test               # full regression suite (all projects)
npm run test:smoke     # @smoke-tagged specs only, headed
npm run test:headed    # any spec, headed
npm run report         # open the last HTML report
```

### Notes

- `pages/alerts-at-geofence.page.ts` and `pages/alerts-at-geofence-detail.page.ts`
  are built from the real component templates/classes (`AlertsAtGeofenceComponent`,
  `AlertsAtGeofenceDetailComponent`, the shared `px-table`/`px-select-inline`/
  `px-calendar` components) — no `data-testid` placeholders remain.
- The filter widgets (`px-select-inline`, `px-calendar`) are bespoke overlay
  components with no native ARIA roles/labels; locators drive them by real CSS
  class + click-to-open/click-option, not `getByRole`/`getByLabel`.
- `setCustomDateDay()` does **not** navigate months in the calendar overlay —
  it only picks a day visible in the currently-displayed month. TC-SGA-011
  is `fixme` until that's extended for a reliable >30-day-ago / invalid-range pick.
- Env-driven test data (`E2E_SGA_*` in `.env.example`) needs real Asset and
  Geofence names from the target account/environment.
