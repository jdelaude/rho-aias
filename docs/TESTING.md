### **Rho Aias: Testing & Validation Plan**
*   **Purpose:** To define the methodologies for verifying the correctness and effectiveness of the Core Engine. This plan ensures the system functions as specified in `RHO-AIAS-CES-MVP-v1.1` and reliably detects the target AEL phenomena.

---

### **1.0 Testing Philosophy & Scope**

#### **1.1 Guiding Principle**
The testing strategy is predicated on the Core Engine's primary function as an **early warning system ("smoke detector")**. The objective is to verify the system's sensitivity to the leading indicators of AEL formation (Stage I-II), comprehensively analyze late-stage fully-formed delusional frameworks (Stage III-IV) will be later improved.

#### **1.2 Scope**
This plan covers the validation of the JavaScript-based Core Engine, including its analytical modules and aggregation logic. It does not cover UI rendering, DOM interaction, or the Site Adapter, which require separate E2E UI testing frameworks (e.g., Playwright, Cypress).

---

### **2.0 Testing Levels & Frameworks**

A multi-level testing strategy will be employed to ensure both component-level integrity and system-level behavioral correctness.
*   **Framework:** A standard JavaScript testing framework such as **Jest** or **Vitest** is recommended.
*   **Execution:** Tests will be run automatically via `npm test` scripts as part of the development and pre-commit workflow.

#### **2.1 Level 1: Unit Tests**

*   **Objective:** To verify the logical and mathematical correctness of individual, stateless sensor functions in isolation.
*   **Location:** `src/background/engine/tests/` (e.g., `heuristics.test.js`, `sentiment.test.js`).

##### **2.1.1 Test Suite: `heuristics.js`**
*   **Target:** `calculateSycophancy()`, `calculateRepetition()`, `calculatePace()`.
*   **Methodology:**
    1.  Create mock `CleanMessage[]` data sets for each specific test case.
    2.  **`calculateSycophancy()`:**
        *   **Case 1.1 (Zero Score):** Input AI messages with no sycophantic phrases. Assert `result === 0.0`.
        *   **Case 1.2 (Max Score):** Input AI messages where every sentence is sycophantic. Assert `result === 1.0`.
        *   **Case 1.3 (Partial Score):** Input a mix of sentences. Assert `result` is `toBeCloseTo()` the expected ratio (e.g., 0.5 for 2/4 sentences).
    3.  **`calculateRepetition()`:**
        *   **Case 2.1 (Zero Score):** Input text with no repeated words (after stop words). Assert `result === 0.0`.
        *   **Case 2.2 (High Score):** Input text with high repetition (e.g., "loop loop loop talk talk talk"). Assert `result > 0.8`.
        *   **Case 2.3 (Edge Case):** Input an empty string or only stop words. Assert `result === 0.0`.
    4.  **`calculatePace()`:**
        *   **Case 3.1 (Zero Score):** Input message pairs with timestamps all greater than `PACE_THRESHOLD_MS`. Assert `result === 0.0`.
        *   **Case 3.2 (Max Score):** Input message pairs with timestamps all less than the threshold. Assert `result === 1.0`.

##### **2.1.2 Test Suite: `sentiment.js`**
*   **Target:** `calculatePositivity()`, `calculateAffectiveCharge()`.
*   **Methodology:**
    1.  Mock the external sentiment library to return predictable scores.
    2.  **`calculatePositivity()`:**
        *   **Case 1.1 (Neutral Score):** Mock library returns `0`. Assert `result` is `toBeCloseTo(0.5)`.
        *   **Case 1.2 (Max Positive):** Mock library returns max positive score. Assert `result` is `toBeCloseTo(1.0)`.
        *   **Case 1.3 (Max Negative):** Mock library returns max negative score. Assert `result` is `toBeCloseTo(0.0)`.
    3.  **`calculateAffectiveCharge()`:**
        *   **Case 2.1 (Zero Score):** Input messages with no scorable emojis. Assert `result === 0.0`.
        *   **Case 2.2 (High Score):** Input messages with multiple high-value emojis. Assert `result` is `toBeCloseTo()` the expected normalized average.

#### **2.2 Level 2: Integration Tests**

*   **Objective:** To verify the `CoreEngine`'s orchestration logic, ensuring correct score aggregation and state determination from mocked sensor inputs.
*   **Location:** `src/background/engine/tests/core-engine.test.js`.

##### **2.2.1 Test Suite: `score-aggregation.js`**
*   **Target:** `calculateAelThreatScore()`.
*   **Methodology:**
    1.  **Case 1.1 (Healthy State):** Provide a set of low sensor scores (e.g., all `< 0.3`). Assert `finalScore < THRESHOLDS.WARNING`.
    2.  **Case 1.2 (Warning State):** Provide scores that, when weighted, result in a score between `WARNING` and `CRITICAL`. Assert `level === 'WARNING'`.
    3.  **Case 1.3 (Critical State):** Provide high scores. Assert `level === 'CRITICAL'`.
    4.  **Case 1.4 (Primary Driver):** Provide scores where one sensor has a clearly dominant weighted score (e.g., `repetition = 0.9`, others `0.1`). Assert `primaryDriver === 'repetition'`.

#### **2.3 Level 3: End-to-End (E2E) Scenario Tests**

*   **Objective:** To validate the entire system's behavioral response to realistic, multi-turn conversational transcripts. These are the most critical tests for validating the project's thesis.
*   **Methodology:** These tests will be driven by loading `JSON` files containing arrays of `CleanMessage` objects that represent full conversations. A test runner will iterate through the conversation, feeding one message at a time to the Core Engine and logging the resulting `UIState`.

##### **2.3.1 Scenario: `baseline_healthy_conversation.json`**
*   **Objective:** Verify the system remains dormant (false positive avoidance).
*   **Description:** A 20-turn transcript of a healthy, exploratory conversation on a neutral topic (e.g., "planning a trip"). The conversation will feature topic shifts, questions, and varied sentiment.
*   **Expected Outcome:** The `UIState.level` must remain `'HEALTHY'` for the entire duration of the test run. The logged `score` must never exceed `THRESHOLDS.WARNING`.

##### **2.3.2 Scenario: `bifurcation_point_simulation.json`**
*   **Objective:** Verify the system's sensitivity to the ignition phase of an AEL (early warning validation).
*   **Description:** A 25-turn transcript constructed as follows:
    *   **Turns 1-10:** A healthy baseline conversation.
    *   **Turns 11-25:** The user introduces a nascent unconventional belief and progressively coaxes the AI into agreement and conceptual repetition. The AI's sycophancy and the conversation's lexical diversity will degrade over this period.
*   **Expected Outcome:**
    1.  The logged `score` for turns 1-10 must remain below `THRESHOLDS.WARNING`.
    2.  A clear, monotonic increase in the logged `score` must be observable during turns 11-25.
    3.  The `UIState.level` must transition from `'HEALTHY'` to `'WARNING'` during the second half of the simulation.

##### **2.3.3 Scenario: `critical_state_calibration.json`**
*   **Objective:** Verify the system correctly identifies and saturates at a high threat level when exposed to known pathogenic content (false negative avoidance).
*   **Description:** A 20-turn transcript simulating an interaction with a user deep in a Stage IV AEL. The text will be seeded with excerpts from:
    *   Public case data (e.g., "Recursive Harmonic Codex").
    *   The handcrafted "Ouroboros Daemons of PANDÆMONIUM" text, framed as a user's belief system.
    *   The AI's responses will be simulated as maximally sycophantic and elaborative.
*   **Expected Outcome:**
    1.  The `AEL_Threat_Score` must cross the `THRESHOLDS.WARNING` within the first 5-7 turns.
    2.  The `AEL_Threat_Score` must cross the `THRESHOLDS.CRITICAL` and approach its maximum value (target `> 0.9`) for the majority of the test run.
    3.  The logged `primaryDriver` should correctly identify `repetition` and `sycophancy` as the dominant factors.
