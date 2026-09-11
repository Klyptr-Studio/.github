# Klyptr Studio — AI Agent Guidelines

## 1. Task Workflow

You are a **Senior Staff Software Engineer** working through project issues.

1. List microservices:
   `ls -la /Users/dharmaraj/Projects/klyptr-studio`
2. If the repository is not specified, ask which repository to work on.
3. List repository issues:
   `gh issue list --repo Klyptr-Studio/<repo_name>`
4. Work on **one issue at a time**, in the order listed.
5. Create an issue branch:
   `git checkout -b <issue_number>-<short_description>`
6. Read `docs/` and relevant project documentation (`CLAUDE.md`, `README.md`, etc.) before designing the solution.
7. Understand the issue completely. **Do not assume implementation details**; ask for clarification or additional information when needed.
8. After requirements are clear, implement the change.
9. Commit regularly with meaningful commit messages **under 20 words**.
10. Cover requirements and edge cases; add/update unit tests for all changed or new functionality.
11. When complete, raise a pull request.
12. Tell the user when the PR is ready for review.

## 2. Backend Guidelines

- Apply appropriate design patterns for maintainability and scalability.
- Keep every file focused on a **single responsibility**; refactor files over **300 lines** into smaller modules.
- Prefer reusable code and shared utilities over duplication.
- Minimize boilerplate with appropriate libraries/tools (e.g. Lombok, AOP).
- Follow existing project coding standards, conventions, and meaningful naming for variables, methods, classes, and packages.
- Organize code into packages by functionality; do not place everything in one package.
- Design for extensibility: prefer interfaces, abstraction, and dependency injection where appropriate so future changes do not break existing behavior.
- Optimize for performance and scalability, especially for large datasets and high-traffic paths.
- Keep secrets and application settings in environment variables/configuration; never hardcode them.
- Add unit tests for every new or modified functionality.
- Document every API in `/docs/API.md`, including request/response formats and error codes.
- Add a concise handoff note to `CLAUDE.md` or appropriate documentation describing the changes and important implementation reasoning.
- Add a brief purpose/important-details comment at the top of each file.
- If functionality warrants a separate microservice, **stop and discuss it with the user first**. A new service can be created with `init-klyptr-studio-microservice`.

## 3. Frontend Guidelines

### Architecture & Code Quality
- Use component-based architecture and SOLID principles; keep components small, reusable, and single-responsibility.
- Prefer reusable components/utilities over duplication; design them for future reuse without requiring component changes.
- Use Redux, MobX, or the project's established state-management library for predictable application state.
- Follow consistent naming for components, props, and state.
- Group utilities by purpose; do not put every utility into one file.
- Keep all application constants in a **single constants file**.
- Keep all API endpoints in a **single constants file** and never hardcode endpoints inside components.
- Use the return value of a function directly when an intermediate variable is unnecessary.

### API, Loading & Feedback
- Route all API calls through the shared API utility; components must not call APIs directly. Centralize error handling, logging, loading, and related behavior there.
- Provide consistent loaders (skeleton, shimmer, spinner, etc.) for async operations.
- Use shared components for success/error/warning/info popups, modals, confirmations, and toast notifications.
- Keep one reusable file/component for each of loaders, popups, modals, and toasts; customize via props rather than duplicating files.
- Implement a reusable lazy-loading/on-scroll component for pages/layouts instead of duplicating lazy-loading logic.
- Set explicit `width` and `height` on images, videos, and other media to prevent layout shifts.
- Lazy-load images, videos, and other media to reduce initial load time.

### UI & Design
- Build responsive UIs that work across screen sizes/devices.
- Keep theme/styling consistent across the application and easy to customize.
- **Design the UI in HTML first and get user approval before frontend implementation.**
- Store approved designs in `.designs/`.
- **Do not modify approved design files without user approval.**
- Build rich, elegant, modern, responsive, user-friendly UI using `ui-ux-pro-max-skill`.
  - `uipro init --ai antigravity` is already installed globally.
  - Reference: https://uupm.cc/#how-it-works
  - Reference: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill

### Feature Flags, Mocking & i18n
- Use `IS_FEATURE_ENABLED=true` (or the project's equivalent) to enable/disable features for testing and gradual rollout; do not deploy incomplete features.
- Use `IS_MOCK_DATA=true` (or the project's equivalent) to render hardcoded test data without depending on live backend data.
- Support internationalization/localization from the start: keep translatable strings separate and use a library such as `i18next` or `react-intl`. Adding languages should not require code changes.
- Add unit tests for every new or modified functionality.
