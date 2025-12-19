# Rho Aias: System Architecture

## 1. Introduction

This document provides a detailed overview of the Rho Aias's software architecture. It is intended for developers to understand the system's design principles, component responsibilities, data flow, and scalability patterns. The architecture is designed to be robust, maintainable, and performant, serving as a solid foundation for the MVP and future iterations.

---

## 2. Core Architectural Principles

The following principles are the non-negotiable tenets that guide all technical decisions for this project.

#### 2.1. Client-Side & Privacy-First
All computation, including data extraction, analysis, and UI rendering, occurs exclusively within the user's browser (the client). No conversational data, personal information, or analytics are ever transmitted to an external server. This is a foundational promise of the product and a hard technical constraint.

#### 2.2. Performance as a Feature
The extension must have a negligible impact on the host application's performance. CPU and memory usage must be kept to a minimum. Analysis functions must be non-blocking and highly optimized to avoid freezing or slowing down the user's browsing experience. This principle directly informs the choice to use a lightweight heuristic engine over a full ML model for the MVP.

#### 2.3. State-Driven, Declarative UI
The user interface modules (`Aura`, `Anchor`) are "dumb." They contain no complex application logic. Their role is solely to render a state object provided by the Core Engine. The engine is the single source of truth that dictates the UI's appearance and behavior. This decouples logic from presentation, making the system easier to reason about, test, and debug.

#### 2.4. High Cohesion, Low Coupling (Modularity)
Each module has a single, well-defined responsibility. Modules communicate through clearly defined interfaces (function calls with structured data objects). This allows any module to be refactored, replaced, or tested in isolation without causing cascading failures throughout the system. The Site Adapter pattern is the primary example of this principle in action.

---

## 3. System Components (Module Deep Dive)

This section details the specific responsibilities of each major component as defined in the directory.

```bash
rho-aias/
├── docs/
│   ├── ARCHITECTURE.md
│   └── CONTRIBUTING.md
├── public/
│   ├── assets/
│   │   ├── anchor-icon.svg
│   │   └── logo-128.png
│   └── manifest.json
├── src/
│   ├── background/
│   │   ├── engine/
│   │   │   ├── core-engine.js
│   │   │   ├── heuristics.js
│   │   │   ├── sentiment.js
│   │   │   └── semantic.js
│   │   └── index.js             // Background script main entry point
│   │
│   ├── content/
│   │   ├── adapter/
│   │   │   └── openai.adapter.js
│   │   ├── ui/
│   │   │   ├── aura.js
│   │   │   └── anchor.js
│   │   └── index.js             // Content script main entry point
│   │
│   └── shared/
│       ├── config.js
│       └── logger.js
├── LICENSE
├── README.md
├── .env.example
├── .gitignore
├── package.json
└── vite.config.js
```


---

### 3.1 The Site Adapter (`/src/content/adapter/`)

This module is the sensory organ of the system. It is the only component with direct, read-only access to the host webpage's DOM. Its sole purpose is to observe the page, parse conversations, and translate them into a clean, abstract format, completely insulating the rest of the system from the brittleness of the web. *build a robust error-handling and logging system. When the adapter fails to find a selector, it should fail gracefully and inform the user that "Rho Aias is not compatible with the current version of this website."*

*   **Purpose:** To observe the DOM, parse conversational turns, and emit a standardized data object.
*   **Inputs:** The `window.document` object of the host page.
*   **Outputs:** A "Clean Message Object" sent via the Chrome messaging API.

*   **Schema: `CleanMessage` Object**
    ```typescript
    {
      id: string;          // A unique ID injected into the DOM element (e.g., 'data-rho-aias-id="msg-123"') for later reference by the UI.
      author: 'user' | 'ai';
      text: string;
      timestamp: number;     // Unix timestamp (ms) of when the message was parsed.
    }
    ```

*   **Key Responsibilities:**
    1.  **Initialization:** Reads configured CSS selectors from `/src/shared/config.js` to identify the chat container and message elements.
    2.  **Observation:** Implements a `MutationObserver` to watch the chat container for new `childList` additions (i.e., new messages).
    3.  **Parsing & Tagging:** Implements a parser function (`parseMessageElement`) that:
        *   Accepts a raw `HTMLElement` of a new message.
        *   Determines the `author` based on the element's structure.
        *   Extracts and sanitizes the raw `text`.
        *   Injects a unique `data-rho-aias-id` attribute directly onto the `HTMLElement` for future identification.
        *   Returns a validated `CleanMessage` object.

---

### 3.2 The Core Engine (`/src/background/engine/`)

This module is the "headless" brain of the application, running persistently in the background script. It is a pure, stateful logic container with no knowledge of or access to the DOM. It receives sensory input from the Site Adapter, processes it through its analytical sub-modules, and determines the system's overall state.

*   **Purpose:** To maintain conversational history, perform all heuristic and semantic analysis, and calculate the AEL Threat Score.
*   **Inputs:** A stream of `CleanMessage` objects from the content script.
*   **Outputs:** A "UI State Object" sent back to the content script.

*   **Schema: `UIState` Object**
    ```typescript
    {
      level: 'HEALTHY' | 'WARNING' | 'CRITICAL';
      primaryDriver: string; // The key of the heuristic that contributed most to the score (e.g., 'ENTROPY', 'SYCOPHANCY').
      diagnosticText: string;
      targetMessageId: string; // The ID of the message that triggered this state change, for the UI to target.
      context: {
        score: number;       // The raw, unweighted AEL Threat Score (0.0 - 1.0).
        // ...other data for future features, like keyword lists.
      }
    }
    ```

*   **Key Responsibilities:**
    1.  **State Management:** Maintains a rolling window of the last N `CleanMessage` objects as the conversational history.
    2.  **Orchestration:** Upon receiving a new message, it updates the history and passes it to the analytical sub-modules.
    3.  **Heuristic Analysis (`heuristics.js`):** Implements a suite of lightweight, stateless functions that accept the conversational history and return a score (e.g., `calculatePace`, `calculateEntropy`, `calculateStructuralSycophancy`).
    4. *NLP Analysis (`sentiment.js`):* Integrates with lightweight, client-side NLP libraries to score text for emotional valence. 
    5. **Lexical Divergence Analysis (`lexical-divergence.js`): Implements a TF-IDF algorithm to score the conversation's divergence from a baseline corpus, detecting the emergence of an esoteric lexicon.**
    6.  **Score Aggregation:** Combines the raw scores from all analytical modules into a single, weighted `AEL_Threat_Score` based on weights defined in `/src/shared/config.js`.
    7.  **State Determination:** Translates the final score into a discrete `UIState` object, selecting the appropriate `level` and generating the user-facing `diagnosticText`.

---

### 3.3 The UI Modules (`/src/content/ui/`)

These modules are the actuators of the system. They are "dumb" components that live on the host page. They contain no application logic; their only job is to receive a `UIState` object from the Core Engine and render the corresponding changes to the DOM.

*   **Purpose:** To render visual feedback and interactive tools onto the host page.
*   **Inputs:** A `UIState` object from the Core Engine.
*   **Outputs:** Direct DOM manipulation (creating/updating/removing elements).

*   **Key Responsibilities:**
    1.  **Initialization:** Injects the necessary root `<div>` containers for UI elements onto the page on load.
    2.  **State Synchronization:** Contains a primary `update(state: UIState)` function that is called when a new state is received from the background. This function orchestrates all visual changes.
    3.  **Aura (`aura.js`):**
        *   Manages the Aura `<div>` element.
        *   Updates its CSS class based on `state.level` to change its color and animation.
        *   Populates its tooltip with the `state.diagnosticText` on hover.
    4.  **Anchor (`anchor.js`):**
        *   Manages the Anchor `<a>` icon element.
        *   If `state.level` is `WARNING` or `CRITICAL`, it uses the `state.targetMessageId` to find the correct message element on the page (via `document.querySelector('[data-rho-aias-id="..."]')`).
        *   It then attaches itself adjacent to that element and generates its `href` based on the conversational context.
        *   If `state.level` is `HEALTHY`, it ensures it is hidden.
---

## 4. Data Flow (Lifecycle of a Single Turn)

1. A new message HTMLElement appears in the webpage's DOM.  
2. The MutationObserver within the **Content Script's Site Adapter** detects the change. 
3. The Site Adapter's parser function is called. It injects a unique ID into the HTMLElement and produces a "Clean Message Object" (containing the ID, author, text, etc.). 
4. The **Content Script** sends this Clean Message Object to the Background Script using chrome.runtime.sendMessage.
5. The **Background Script** receives the message and passes it to the **Core Engine**. 
6. The **Core Engine** updates its internal state (conversational history) and runs its analysis functions.
7. The scores are aggregated into a final AEL_Threat_Score. 
8. The score is translated into a final "UI State Object" (containing the new level, diagnosticText, and the targetMessageId of the triggering message).
9. The **Background Script** sends this UI State Object back to the Content Script as a response to the message.  
10. The **Content Script** receives the UI State Object and calls the update() methods on the **UI Modules**, passing them the new state.
11. The **Aura** module changes its color. If the state is WARNING or CRITICAL, the **Anchor** module uses the targetMessageId to find the correct message element on the page and displays itself.
## 5. Future Scalability

This architecture is explicitly designed for future growth.

*   **Multi-Platform Support:** To support a new LLM (e.g., `claude.ai`), only a new adapter file (`claude.adapter.js`) needs to be created. No changes are required in the Core Engine or UI modules.
*   **ML Model Integration:** The Heuristic module's outputs (`paceScore`, `ShannonEntropyScore`, `emojiAnalysis`etc.) serve as a perfectly engineered feature set. A future ML module can be added to the Core Engine. It will consume these heuristic scores (instead of raw text) to produce a more nuanced final AEL Threat Score. This makes the eventual transition to ML a clean upgrade rather than a complete rewrite.




