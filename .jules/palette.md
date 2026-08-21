## 2026-08-21 - Accessible Visual Progress Bars
**Learning:** When implementing visual progress bars using div elements, attaching ARIA progressbar attributes directly to the dynamic inner bar doesn't work well for screen readers. The wrapper container must hold `role="progressbar"`, `aria-valuemin`, and `aria-valuemax`, while `aria-valuenow` must be dynamically synced via JavaScript.
**Action:** Always structure custom progress bars with the wrapper holding static ARIA roles/bounds and dynamic ARIA values, while the inner div handles visual width.
