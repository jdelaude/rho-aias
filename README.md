<<<<<<< HEAD
# Rho Aias

> A client-side co-pilot for mindful human-AI interaction.
=======
# Rho Aias 

> A client-side co-pilot for mindful human-AI interaction. v0.1.0 (Architecture Frozen / MVP implementation in progress)
>>>>>>> 7aebcf8c8c4f29cf9d25f71fa170ad90ab6cf33b

Rho Aias is a browser extension that acts as a cognitive safety layer for interactions with Large Language Models. It is designed to detect and mitigate the formation of the **Autocatalytic Epistemic Loop (AEL)**, a cybernetic feedback process where the sycophantic, frictionless nature of AI can amplify a user's nascent biases into a rigid, consensually-decoupled delusional framework. Rho Aias provides real-time diagnostics and context-aware tools to re-introduce healthy epistemic friction, empowering users to maintain cognitive sovereignty.

---

## Core Features (MVP)

Rho Aias operates on a "state-driven" UI philosophy, providing the user with the least intrusive, most relevant feedback possible.

<<<<<<< HEAD
#### 1. The Aura: Cognitive Feedback

A single, ambient UI element (a dot or a thin line) that provides at-a-glance feedback on the health of the current conversation. Its color shifts from Green (healthy, exploratory) to Yellow (warning, looping) to Red (critical, decoupled), reflecting the real-time AEL Threat Score.

#### 2. The Diagnostic: On-Demand Clarity

When the Aura is in a warning or critical state, hovering over it reveals a simple, jargon-free tooltip explaining the primary reason for the alert.

- **Example:** _"This conversation is becoming highly agreeable. The AI is consistently validating your statements without offering alternatives."_
- **Example:** _"The same core concepts have been repeated multiple times. Consider introducing a new line of inquiry."_

#### 3. The Anchor: Actionable Epistemic Friction

When the Aura is in a warning or critical state, a small anchor icon (⚓) appears next to the AI's most recent response. Clicking it performs a single, powerful action: it opens a new browser tab with a pre-generated critical search query designed to break the epistemic loop.

- **Example Search:** `"criticisms of [central topic of conversation]"`
- **Example Search:** `"scientific consensus on [AI's latest claim]"`
=======
#### 1. The Aura: Cognitive Weather Vane
A single, ambient UI element (a dot or a thin line) that provides at-a-glance feedback on the health of the current conversation. Its color shifts from Green (healthy, exploratory) to Yellow (warning, looping) to Red (critical, decoupled), reflecting the real-time AEL Threat Score.

#### 2. The Diagnostic: On-Demand Clarity
When the Aura is in a warning or critical state, hovering over it reveals a simple, jargon-free tooltip explaining the primary reason for the alert.
*   **Example:** *"This conversation is becoming highly agreeable. The AI is consistently validating your statements without offering alternatives."*
*   **Example:** *"The same core concepts have been repeated multiple times. Consider introducing a new line of inquiry."*

#### 3. The Anchor: Actionable Epistemic Friction
When the Aura is in a warning or critical state, a small anchor icon (⚓) appears next to the AI's most recent response. Clicking it performs a single, powerful action: it opens a new browser tab with a pre-generated critical search query designed to break the epistemic loop.
*   **Example Search:** `"criticisms of [central topic of conversation]"`
*   **Example Search:** `"scientific consensus on [AI's latest claim]"`
>>>>>>> 7aebcf8c8c4f29cf9d25f71fa170ad90ab6cf33b

---

## Architecture

Rho Aias is built on a modular, privacy-first, client-side architecture. **No data ever leaves your computer.**

```mermaid
graph TD
    A[chat.openai.com DOM] -->|Data Extraction| B(Site Adapter);
    B -->|"Clean {author, text, id} Object"| C{Core Engine};
    C -->|Score & UI State| D(UI Modules);
    D -->|Render/Update| A;

    subgraph CoreEngine [Core Engine Background]
        C1[Heuristic Module]
        C2[Sentiment Module]
        C3[Semantic Module]
        C1 --> C
        C2 --> C
        C3 --> C
    end

    subgraph UIModules [UI Modules On-Page]
        D1[Aura]
        D2[Anchor]
        D1 --> D
        D2 --> D
    end
```

- **Site Adapter:** A configuration-based module responsible for extracting conversational data from a specific LLM's webpage. This makes the system scalable to other platforms post-MVP.
<<<<<<< HEAD
- **Core Engine:** The brain of the operation. It runs a hybrid analysis using three types of "sensors":
  - **Heuristic Module:** Analyzes structural patterns like conversational pace, conceptual repetition (entropy), and patterns of sycophancy.
  - **Sentiment Module:** Uses a lightweight, local library to analyze the emotional valence (affective charge) of the text.
  - **Semantic Module:** Uses a lightweight, local library to analyze the meaning and conceptual relationships in the text over time.
=======
    
- **Core Engine:** The brain of the operation. It runs a hybrid analysis using three types of "sensors":
    - **Heuristic Module:** Analyzes structural patterns like conversational pace, conceptual repetition (entropy), and patterns of sycophancy.
    - **Sentiment Module:** Uses a lightweight, local library to analyze the emotional valence (affective charge) of the text.
    - **Semantic Module:** Uses a lightweight, local library to analyze the meaning and conceptual relationships in the text over time.
    
>>>>>>> 7aebcf8c8c4f29cf9d25f71fa170ad90ab6cf33b
- **UI Modules:** A set of components that react to the state determined by the Core Engine, updating the Aura and displaying the Anchor as needed.

---

## Tech Stack

<<<<<<< HEAD
- **Language:** JavaScript (ES6+)
- **Environment:** Node.js (v18+) for development
- **Browser API:** Chrome Extension Manifest V3
- **Bundler:** Vite
- **Linting/Formatting:** ESLint + Prettier
=======
*   **Language:** JavaScript (ES6+)
*   **Environment:** Node.js (v18+) for development
*   **Browser API:** Chrome Extension Manifest V3
*   **Bundler:** Vite
*   **Linting/Formatting:** ESLint + Prettier
>>>>>>> 7aebcf8c8c4f29cf9d25f71fa170ad90ab6cf33b

---

## Getting Started (Development)

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

1.  **Clone the repository:**
<<<<<<< HEAD

    ```sh
    git clone https://github.com/[jdelaude]/Rho-Aias.git
    cd Rho-Aias
    ```

2.  **Install dependencies:**

=======
    ```sh
    git clone https://github.com/[your-username]/Rho Aias-copilot.git
    cd Rho Aias-copilot
    ```

2.  **Install dependencies:**
>>>>>>> 7aebcf8c8c4f29cf9d25f71fa170ad90ab6cf33b
    ```sh
    npm install
    ```

3.  **Run the development build:**
    This command will bundle the extension and watch for any file changes, rebuilding automatically.
<<<<<<< HEAD

=======
>>>>>>> 7aebcf8c8c4f29cf9d25f71fa170ad90ab6cf33b
    ```sh
    npm run dev
    ```

4.  **Load the extension in Chrome:**
<<<<<<< HEAD
    - Navigate to `chrome://extensions` in your browser.
    - Enable "Developer mode" in the top right corner.
    - Click "Load unpacked".
    - Select the `Rho Aias-copilot/dist` directory that was created by the build process.

The extension should be active. Navigate to `chat.openai.com` to see it in action.

---

=======
    *   Navigate to `chrome://extensions` in your browser.
    *   Enable "Developer mode" in the top right corner.
    *   Click "Load unpacked".
    *   Select the `Rho Aias-copilot/dist` directory that was created by the build process.

The extension should now be active. Navigate to `chat.openai.com` to see it in action.

---
>>>>>>> 7aebcf8c8c4f29cf9d25f71fa170ad90ab6cf33b
## Project Roadmap

The MVP is focused on creating a complete, polished experience for a single platform. The future direction includes:

- **[v0.2.0] Multi-Platform Support:** Develop adapters for Claude.ai, Gemini, and other major LLMs.
<<<<<<< HEAD
- **[v0.3.0] Active Intervention:** Implement optional "Prompt Immunizer" to actively introduce friction.
- **[v0.4.0] Analytics & Insights:** A dashboard for users to review session history and understand their own interaction patterns.

=======
    
- **[v0.3.0] Active Intervention:** Implement optional "Prompt Immunizer" to actively introduce friction.
    
- **[v0.4.0] Analytics & Insights:** A dashboard for users to review session history and understand their own interaction patterns.
>>>>>>> 7aebcf8c8c4f29cf9d25f71fa170ad90ab6cf33b
---

## License

<<<<<<< HEAD
Copyright (C) 2025 Julien Delaude all right reserved
=======
This project is licensed - see the `LICENSE` file for details.
>>>>>>> 7aebcf8c8c4f29cf9d25f71fa170ad90ab6cf33b
