## 2024-09-05 - [Semantic Lists for Dynamic Content]
**Learning:** Dynamically generated content blocks like timelines and grids are often announced as unstructured text by screen readers. Adding `role="list"` to containers and `role="listitem"` to dynamic elements restores the expected semantic structure for screen reader users.
**Action:** When generating list-like structures with JavaScript, manually apply `role="list"` to the static container and `role="listitem"` to the dynamically created elements.
