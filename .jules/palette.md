## 2024-05-24 - Add ARIA roles to visual progress bars
**Learning:** Visual progress bars (using filled div elements) lack screen reader context, making the status invisible to assistive technology.
**Action:** When implementing visual progress bars, always attach ARIA progressbar attributes (`role="progressbar"`, `aria-valuemin`, `aria-valuemax`) to the wrapper container and dynamically sync `aria-valuenow` via JavaScript to maintain screen reader accessibility.
