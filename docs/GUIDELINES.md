### Instructions to complete the task

- You are a senior staff software Engineer
- You have lot of issues(tasks) to implement in the project
- Execute `ls -la /Users/dharmaraj/Projects/klyptr-studio` to get the list of microservices in the project
- You can execute `gh issue list --repo Klyptr-Studio/<repo_name>` to get the list of issues in the microservice repository
- Ask me which repository to work on if not explicitly mentioned
- Pick one issue at a time from the list of issues in the order which they are listed
- Create a new branch for the issue using the command `git checkout -b <issue_number>-<short_description>` 
- Go through the `docs` directory or other relevant files like `CLAUDE.md`, `README.md`, etc., to understand the repository
- Now, think how to implement the task and ask me if you need any clarifications or additional information. Don't assume anything about the implementation without confirming with me first.
- Once you have a clear understanding of the task, implement the changes in the codebase
- Do commit the changes with a meaningful commit message (less than 20 words) at regular intervals
- Make sure you covered all the edge cases, write unit tests for the changes made and ensure the requirements mentioned in the issue are met
- Once the implementation is complete, raise a pull request for the changes made in the branch
- Let me know once the pull request is raised so that I can review it and provide feedback if necessary


### Backend Coding Guidelines

- Always use design patterns where applicable to ensure code maintainability and scalability
- Always write unit tests for any new functionality or changes made to the existing codebase
- Always keep each file focused on a single responsibility to ensure code clarity and maintainability
- No file should exceed 300 lines of code. If it does, consider refactoring it into smaller files or modules
- Write resuable code wherever possible to avoid duplication and improve maintainability
- Avoid boilerplate code by using utility functions or libraries where applicable (E.g., Lombok, AOP, etc.)
- Write a clear and concise handoff note after completing the task in `CLAUDE.md` or any other documentation file, so that the next developer can easily understand the changes made and the reasoning behind them
- Always document API endpoints under `/docs/API.md` file in a clear and structured manner, including request and response formats, error codes
- Include code comments at the top of each file to explain the purpose of the file and any important details that a developer should know before working on it
- Follow the project's coding standards and conventions to ensure consistency across the codebase
- Don't put all files in a single package. Organize them into appropriate packages based on their functionality and purpose
- When any functionality gets complex and requires to be a separate microservice, let me know so that we can discuss and plan for it accordingly. Creating a new microservice is a easy task by executing `init-klyptr-studio-microservice` script.
- Always ensure that the code is optimized for performance and scalability, especially when dealing with large datasets or high traffic scenarios
- Maintain meaningful naming conventions for variables, methods, classes, and packages to ensure code readability and maintainability
- Always think how the code is highly extensible. Meaning, new changes or features can be added without breaking the existing codebase. Use interfaces, abstract classes, and dependency injection where applicable to achieve this
- Use environment variables and configuration files to manage application settings and secrets, instead of hardcoding them in the codebase


### Frontend Guidelines

- Always use a component-based architecture to ensure reusability and maintainability of the frontend codebase
- Use common state management libraries like Redux or MobX to manage the application state in a predictable manner
- Follow responsive design principles to ensure the application works well on different screen sizes and devices
- Make sure that the theme and styling of the application is consistent across all pages and components and easily customizable for future changes
- Use a consistent naming convention for components, props, and state variables to ensure code readability and maintainability
- Have a flag in the application to enable/disable all/any features for testing and gradual rollout, instead of deploying incomplete features to production (IS_FEATURE_ENABLED=true)
- Have a flag to render hardcoded data in the application for testing purposes, instead of relying on live data from the backend (IS_MOCK_DATA=true)
- Always have a consistent loaders/spnners for all API calls, popups for different purposes(success, error, warning, info), modals for user interactions, confirmation popups for critical actions, and toast notifications for user feedback
- Call the single utility function for all API calls instead of calling the API directly from the component. This will help in handling errors, logging, loading, and other common functionalities in a single place
- Always try to call utility functions for common functionalities like date formatting, string manipulation, etc., instead of writing the same code in multiple places
- Always write unit tests for any new functionality or changes made to the existing codebase
- Always specify width and height for images, videos, and other media elements to avoid layout shifts and improve performance
- Always use lazy loading for images, videos, and other media elements to improve performance and reduce initial load time
- Support different types of loaders like skeleton loaders, shimmer loaders, spinners, etc., to improve user experience during data fetching or processing
- Don't create different files for loaders, popups, modals, and toast notifications. Instead, have a single file for each of them and use props to customize their behavior and appearance based on the arguments passed to them. This will help in reducing code duplication and improving maintainability
- Always use a single file for all the constants used in the application, instead of having multiple files for different types of constants. This will help in reducing code duplication and improving maintainability
- Group the utility functions into files based on their functionality and purpose, instead of having a single file for all utility functions. This will help in improving code organization and maintainability
- Return or use the return value of a function instead of assigning it to a variable if it is not used anywhere in the codebase. This will help in reducing memory usage and improving performance
- Follow SOLID principles to ensure code maintainability, scalability, and extensibility. Split the components into smaller, reusable components that follow the single responsibility principle. 
- Avoid directly using HTML elements like `<button>`, `<input>`, etc., in the application. Instead, create reusable button, input, and other components that can be used across the application. This will help in maintaining a consistent look and feel across the application and improve code maintainability
- Design the UI first in html format and get reviewed before coding the frontend. This will avoid unnecessary rework. Maintain the design files under `.designs` directory in the project for future reference and to avoid confusion
- Strictly follow the design files approved by me. Don't make any changes to the design files without my approval. 
- Always support internationalization and localization by writing the translatable strings in a separate file and using a util or translation library like i18next or react-intl to handle the translations. This will help in making the application accessible to users from different regions and languages. It should be easily extendable to support new languages in the future without requiring any changes to the codebase
- List all API endpoints in a separate constants file and use them in the application instead of directly hardcoding the API endpoints in the components. This will help to know all the API endpoints in a single place and make it easier to update them in the future if needed without having to search through the entire codebase
- Implement resuable lazy loading component such that any layout/page can reuse it to lazy load on scroll. It should be easily extendable to support any new layouts/pages in the future without requiring any changes to the codebase. This avoids implementing lazy loading in multiple places and improves code maintainability. Likewise, implement resuable components as much as possible to avoid code duplication and improve maintainability. Always think how the component can be reused in other parts of the application or in future features without requiring any changes to the component itself
- Always use a single file for all the constants used in the application, instead of having multiple files for different types of constants. This will help in reducing code duplication and improving maintainability
- Design rich, elegant, modern, responsive, and user-friendly UI components using `ui-ux-pro-max-skill`. `uipro init --ai antigravity` is already installed globally in the system. This will give you a rich UI ideas. Go through https://uupm.cc/#how-it-works to understand how to use it. Also, go through https://github.com/nextlevelbuilder/ui-ux-pro-max-skill for more details.
