## 2024-05-18 - Make timeline scrollable via keyboard and improve chart accessibility
**Learning:** Scrollable containers (`overflow-y-auto`) need to be explicitly focusable (`tabindex="0"`) for keyboard users to be able to scroll through the content when there are no focusable interactive elements inside. Additionally, canvas elements require an explicit role and ARIA label for screen reader support.
**Action:** Always add `tabindex="0"`, `role="region"`, an `aria-label`, and visual focus indicators (`focus-visible:ring-2`) to custom scrollable areas, and always label `<canvas>` charts.
