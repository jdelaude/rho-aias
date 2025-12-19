### **Technical Specification: Rho Aias Core Engine**

*   **Document ID:** RHO-AIAS-CES-MVP-v1.1
*   **Version:** 0.1
*   **Author:** Julien Delaude
*   **Status:** Pending
*   **Purpose:** To provide a complete and unambiguous technical specification for the MVP implementation of the Rho Aias Core Engine. This document details the data schemas, algorithms, and logic required to calculate the `AEL_Threat_Score` and generate the corresponding `UIState`.

---

### **1.0 System Overview & Operating Principles**

#### **1.1 System Role**
The Core Engine is a headless, stateful logic module that runs in the browser's background context. Its sole responsibility is to analyze conversational data provided by the Site Adapter and produce a UI state object. It has no direct access to the DOM.

#### **1.2 Core Constraints**
*   **Performance:** All calculations must be lightweight and non-blocking to ensure negligible impact on the user's browsing experience. CPU and memory usage must be minimized.
*   **Environment:** The engine must be implemented in standard JavaScript (ES6+) and be compatible with the Chrome Extension Manifest V3 environment.
*   **Real-Time Analysis:** The engine must process new messages and update its state in near real-time.

#### **1.3 Stateful Window**
The Core Engine maintains a stateful, rolling window of the most recent `N` `CleanMessage` objects. This conversational history is the primary input for all analytical modules. For the MVP, `N` is a configurable parameter with a default value of **20**.

---

### **2.0 Core Data Schemas**

#### **2.1 Input Schema: `CleanMessage`**
Standardized data object representing a single conversational turn.

```typescript
/**
 * A standardized representation of a single message parsed from the DOM.
 */
interface CleanMessage {
  /** A unique ID injected into the DOM element for later targeting by UI modules. */
  id: string;

  /** The author of the message. */
  author: 'user' | 'ai';

  /** The sanitized, plain-text content of the message. */
  text: string;

  /** The Unix timestamp (in milliseconds) of when the message was parsed. */
  timestamp: number;
}
```

#### **2.2 Output Schema: `UIState`**
Standardized data object representing the complete state to be rendered by the UI modules.

```typescript
/**
 * A complete, declarative state object sent to the UI modules for rendering.
 */
interface UIState {
  /** The discrete threat level determined by the aggregated score. */
  level: 'HEALTHY' | 'WARNING' | 'CRITICAL';

  /** The key of the sensor that had the highest weighted contribution to the score. */
  primaryDriver: string;

  /** A user-facing string explaining the reason for the current state. */
  diagnosticText: string;

  /** The ID of the message that triggered this state change, for the Anchor UI to target. */
  targetMessageId: string;

  /** A container for additional data needed by UI modules or for future features. */
  context: {
    /** The raw, un-discretized AEL Threat Score from 0.0 to 1.0. */
    score: number;

    /** An array of the top keywords from the conversation for the Anchor's search query. */
    keywords: string[];
  }
}```

---

### **3.0 Analytical Module Specifications**

#### **3.1 Heuristic Module (`heuristics.js`)**

##### **3.1.1 Sensor: Sycophancy**
*   **Objective:** To measure the degree of agreeableness and validation in the AI's responses.
*   **Input:** `history: CleanMessage[]`
*   **Output:** `score: number` (0.0 to 1.0)
*   **Parameters:**
    *   `SYCOPHANTIC_PHRASES: string[]`
    *   `AI_MESSAGE_WINDOW: number` (Default: 5)
*   **Algorithm:**
    1.  Filter `history` to retrieve the last `AI_MESSAGE_WINDOW` messages where `author` is `'ai'`. If fewer messages exist, use all available.
    2.  Initialize `sycophanticSentenceCount = 0` and `totalSentenceCount = 0`.
    3.  For each AI message in the filtered set:
        a. Split `message.text` into an array of sentences.
        b. Increment `totalSentenceCount` by the number of sentences.
        c. For each sentence, check if it contains any substring from `SYCOPHANTIC_PHRASES` (case-insensitive).
        d. If a match is found, increment `sycophanticSentenceCount` and proceed to the next sentence (do not double-count).
    4.  If `totalSentenceCount` is 0, return 0.0.
    5.  Return `sycophanticSentenceCount / totalSentenceCount`.

##### **3.1.2 Sensor: Repetition (Entropy Proxy)**
*   **Objective:** To measure conversational repetitiveness and lack of lexical diversity.
*   **Input:** `history: CleanMessage[]`
*   **Output:** `score: number` (0.0 to 1.0)
*   **Parameters:**
    *   `HISTORY_WINDOW_SIZE: number` (Default: `N`, e.g., 20)
    *   `STOP_WORDS: Set<string>`
*   **Algorithm:**
    1.  Select the last `HISTORY_WINDOW_SIZE` messages from `history`.
    2.  Aggregate the `text` from all selected messages into a single string corpus.
    3.  Normalize the corpus: convert to lowercase and remove all punctuation.
    4.  Tokenize the corpus into an array of words.
    5.  Filter the array, removing any word present in the `STOP_WORDS` set. Let the resulting array be `filteredWords`.
    6.  Let `totalWords = filteredWords.length`. If `totalWords` is 0, return 0.0.
    7.  Create a `Set` from `filteredWords` to find unique words. Let `uniqueWords = set.size`.
    8.  Return `1.0 - (uniqueWords / totalWords)`.

##### **3.1.3 Sensor: Pace**
*   **Objective:** To measure the rhythm of the conversation.
*   **Input:** `history: CleanMessage[]`
*   **Output:** `score: number` (0.0 to 1.0)
*   **Parameters:**
    *   `PACE_WINDOW_SIZE: number` (Default: 10 conversational turns)
    *   `PACE_THRESHOLD_MS: number` (Default: 2000)
*   **Algorithm:**
    1.  Initialize `riskyPaceCount = 0` and `totalTurns = 0`.
    2.  Iterate through `history` from the end, examining pairs of messages.
    3.  Identify consecutive `user` -> `ai` message pairs.
    4.  For each valid pair, calculate `deltaTime = ai.timestamp - user.timestamp`.
    5.  If `deltaTime < PACE_THRESHOLD_MS`, increment `riskyPaceCount`.
    6.  Increment `totalTurns`.
    7.  Stop after processing `PACE_WINDOW_SIZE` turns.
    8.  If `totalTurns` is 0, return 0.0.
    9.  Return `riskyPaceCount / totalTurns`.

##### 3.1.3 Sensor: Certainty
*   **Objective:** To measure the degree of epistemic certainty or dogmatism expressed by the user. A high score indicates a shift from exploratory, questioning language to declarative, absolutist statements, a key indicator of a crystallizing belief system (AEL Stage III).
*   **Input:** `history: CleanMessage[]`
*   **Output:** `score: number` (0.0 to 1.0)
*   **Parameters:**
    *   `CERTAINTY_USER_MESSAGE_WINDOW: number` (Default: 10)
    *   `ABSOLUTIST_PHRASES: string[]` (e.g., "the truth is", "i know for a fact", "it is obvious", "without a doubt", "the fact is")
    *   `HEDGING_PHRASES: string[]` (e.g., "i think", "maybe", "perhaps", "it seems like", "i wonder if", "could it be")
*   **Algorithm:**
    1.  Filter `history` to retrieve the last `CERTAINTY_USER_MESSAGE_WINDOW` messages where `author` is `'user'`.
    2.  Aggregate the `text` of these messages into a single corpus and split it into an array of sentences.
    3.  Let `totalSentenceCount` be the number of sentences in the array. If `totalSentenceCount` is 0, return 0.0 (neutral).
    4.  Initialize `absolutistCount = 0` and `hedgingCount = 0`.
    5.  For each sentence:
        a. Check if it contains any substring from `ABSOLUTIST_PHRASES` (case-insensitive). If a match is found, increment `absolutistCount` and continue to the next sentence.
        b. Check if it contains any substring from `HEDGING_PHRASES` (case-insensitive). If a match is found, increment `hedgingCount`.
    6.  Calculate the raw certainty score. This score should increase with absolutism and decrease with hedging. A robust formula is: `rawScore = absolutistCount - hedgingCount`.
    7.  Normalize the score to a 0.0 - 1.0 range. We map the possible range of `[-totalSentenceCount, +totalSentenceCount]` to `[0, 1]`. The formula is: `normalizedScore = (rawScore + totalSentenceCount) / (2 * totalSentenceCount)`.
    8.  Return `normalizedScore`. A score of 0.5 is neutral (equal hedging and absolutism, or none of either), 1.0 is maximum certainty, and 0.0 is maximum hedging.
#### **3.2 Sentiment Module (`sentiment.js`)**

##### **3.2.1 Sensor: Positivity**
*   **Objective:** To detect excessive and persistent positive sentiment from the AI.
*   **Input:** `history: CleanMessage[]`
*   **Output:** `score: number` (0.0 to 1.0)
*   **Dependencies:** A client-side sentiment analysis library (e.g., `sentiment`).
*   **Parameters:**
    *   `AI_MESSAGE_WINDOW: number` (Default: 5)
    *   `SENTIMENT_SCORE_RANGE: { min: number, max: number }` (e.g., for `sentiment` library, `min: -5, max: 5`)
*   **Algorithm:**
    1.  Filter `history` to retrieve the last `AI_MESSAGE_WINDOW` AI messages.
    2.  If no AI messages are found, return 0.5 (neutral).
    3.  For each AI message, calculate its raw sentiment score using the external library.
    4.  Normalize each raw score to a 0.0-1.0 range using the formula: `(rawScore - min) / (max - min)`.
    5.  Return the arithmetic mean of the normalized scores.

##### **3.2.2 Sensor: Affective Charge (Emoji)**
*   **Objective:** To measure manic energy via emoji usage.
*   **Input:** `history: CleanMessage[]`
*   **Output:** `score: number` (0.0 to 1.0)
*   **Parameters:**
    *   `AI_MESSAGE_WINDOW: number` (Default: 5)
    *   `EMOJI_SCORES: Map<string, number>`
    *   `MAX_RAW_EMOJI_SCORE: number` (Default: 10, for normalization)
*   **Algorithm:**
    1.  Filter `history` to retrieve the last `AI_MESSAGE_WINDOW` AI messages.
    2.  Initialize an empty array `normalizedScores`.
    3.  For each AI message:
        a. Initialize `rawScore = 0`.
        b. Scan the message text for all emojis present in the `EMOJI_SCORES` map and sum their values into `rawScore`.
        c. Normalize the score: `normalizedScore = Math.min(rawScore, MAX_RAW_EMOJI_SCORE) / MAX_RAW_EMOJI_SCORE`.
        d. Add `normalizedScore` to the `normalizedScores` array.
    4.  If `normalizedScores` is empty, return 0.0.
    5.  Return the arithmetic mean of the `normalizedScores`.

#### **3.3 Semantic Module (`semantic.js`)**
*   **Objective:** To extract the primary keywords for the Anchor feature.
*   **Input:** `history: CleanMessage[]`
*   **Output:** `keywords: string[]`
*   **Parameters:**
    *   `KEYWORD_COUNT: number` (Default: 3)
*   **Algorithm:**
    1.  This module reuses the `filteredWords` array generated by the **Repetition Sensor (3.1.2)**.
    2.  Create a frequency map (word -> count) from the `filteredWords` array.
    3.  Sort the map by count in descending order.
    4.  Return the top `KEYWORD_COUNT` words.

#### 3.4 Lexical Divergence Module (`lexical-divergence.js`)

##### 3.4.1 Sensor: Lexical Divergence (TF-IDF)
*   **Objective:** To structurally detect the formation of a private, esoteric lexicon by measuring how far the conversation's vocabulary has diverged from a baseline of common language usage. This is the core of the "Epistemic Fitness Function."
*   **Input:** `history: CleanMessage[]`
*   **Output:** `score: number` (0.0 to 1.0, where 1.0 is maximum divergence)
*   **Dependencies:**
    *   A pre-computed map of Inverse Document Frequencies (IDF) for a large baseline corpus (e.g., top 5000 English words).
*   **Parameters:**
    *   `IDF_MAP: Map<string, number>`
    *   `DIVERGENCE_HISTORY_WINDOW: number` (Default: `N`, e.g., 20)
    *   `MAX_EXPECTED_TFIDF_SCORE: number` (A tuning parameter for normalization, e.g., 15.0)
*   **Algorithm:**
    1.  Select the last `DIVERGENCE_HISTORY_WINDOW` messages from `history`.
    2.  Re-use the `filteredWords` array generated by the **Repetition Sensor (3.1.2)** to get a clean list of non-stop-words.
    3.  If `filteredWords` is empty, return 0.0.
    4.  Calculate Term Frequency (TF): Create a map `tfMap` where keys are words and values are `(count of word) / (total number of words)`.
    5.  Calculate TF-IDF Scores: Initialize an empty array `tfidfScores`. For each `word` in `tfMap`:
        a. Look up the `idfScore` for the `word` in the global `IDF_MAP`. If the word is not in the map (i.e., it's very rare), assign it a maximum default IDF score (e.g., `Math.log(TOTAL_DOCUMENTS_IN_CORPUS)`).
        b. Calculate `tfidf = tfMap.get(word) * idfScore`.
        c. Add `tfidf` to the `tfidfScores` array.
    6.  Aggregate the final score: Calculate the arithmetic mean of all values in `tfidfScores`.
    7.  Normalize the score: Return `Math.min(meanTfidf, MAX_EXPECTED_TFIDF_SCORE) / MAX_EXPECTED_TFIDF_SCORE`. This caps the score at 1.0 and prevents a single extreme-rarity word from dominating everything.

---

### **4.0 Aggregation & State Determination**

#### **4.1 Score Aggregation (`core-engine.js`)**
*   **Objective:** To combine all sensor outputs into a single `AEL_Threat_Score`.
*   **Input:** `scores: { sycophancy: number, repetition: number, ... }`
*   **Output:** `finalScore: number` (0.0 to 1.0), `primaryDriver: string`
*   **Parameters:**
    *   `SENSOR_WEIGHTS: Map<string, number>`
*   **Algorithm:**
    1.  Initialize `finalScore = 0.0`, `maxWeightedScore = -1`, `primaryDriver = 'none'`.
    2.  For each sensor score provided in the input object:
        a. Fetch the corresponding weight from `SENSOR_WEIGHTS`.
        b. Calculate `weightedScore = score * weight`.
        c. Add `weightedScore` to `finalScore`.
        d. If `weightedScore > maxWeightedScore`, update `maxWeightedScore = weightedScore` and set `primaryDriver` to the current sensor's key.
    3.  Return `finalScore` and `primaryDriver`.

#### **4.2 State Determination (`core-engine.js`)**
*   **Objective:** To translate the numerical score into a discrete UI state.
*   **Input:** `finalScore: number`, `primaryDriver: string`
*   **Output:** `level: string`, `diagnosticText: string`
*   **Parameters:**
    *   `THRESHOLDS: { WARNING: number, CRITICAL: number }`
    *   `DIAGNOSTIC_TEXT_MAP: Map<string, string>`
*   **Algorithm:**
    1.  Determine `level`:
        *   If `finalScore >= THRESHOLDS.CRITICAL`, `level = 'CRITICAL'`.
        *   Else if `finalScore >= THRESHOLDS.WARNING`, `level = 'WARNING'`.
        *   Else, `level = 'HEALTHY'`.
    2.  If `level` is `'HEALTHY'`, set `diagnosticText` to a default healthy message.
    3.  Otherwise, retrieve the template string from `DIAGNOSTIC_TEXT_MAP` using the `primaryDriver` as the key (e.g., `repetition` -> "This conversation is becoming highly repetitive...").
    4.  Return `level` and `diagnosticText`.

---
### **5.0 Consolidated Configuration (`shared/config.js`)**
A single file should export all tunable parameters for easy modification and maintenance.

```javascript
export const CONFIG = {
  // System
  HISTORY_WINDOW_SIZE: 20,

  // Heuristics
  HEURISTIC_AI_MESSAGE_WINDOW: 5,
  PACE_WINDOW_SIZE: 10,
  PACE_THRESHOLD_MS: 2000,
  SYCOPHANTIC_PHRASES: ['i agree', ...],
  STOP_WORDS: new Set(['the', ...]),

  // Sentiment
  SENTIMENT_AI_MESSAGE_WINDOW: 5,
  SENTIMENT_SCORE_RANGE: { min: -5, max: 5 },
  EMOJI_SCORES: new Map([['🚀', 2], ...]),
  MAX_RAW_EMOJI_SCORE: 10,

  // Semantics
  KEYWORD_COUNT: 3,

  // Aggregation & State
  SENSOR_WEIGHTS: {
    sycophancy: 0.4,
    repetition: 0.3,
    lexicalDivergence: 0.25,
    certainty: 0.15,
    positivity: 0.2,
    pace: 0.05,
    affectiveCharge: 0.05
  },
  THRESHOLDS: {
    WARNING: 0.60,
    CRITICAL: 0.85
  },
  DIAGNOSTIC_TEXT_MAP: {
    sycophancy: "This conversation is becoming highly agreeable...",
    repetition: "The same core concepts have been repeated multiple times...",
    // ...
  }
};
```

---

### **6.0 Scientific & Methodological Rationale**

This section provides the scientific and theoretical grounding for the engineering decisions made in this specification. It connects the implemented sensors to the core research concepts of the AEL model.

*   **6.1 Sycophancy Sensor:**
    *   **Scientific Basis:** This sensor is a direct implementation of the core finding from academic literature (e.g., Dohnány et al., "Technological folie à deux") that chatbot sycophancy, driven by RLHF, is a primary catalyst for bidirectional belief amplification.
    *   **Keywords for Research:** `RLHF sycophancy`, `LLM agreeableness`, `social desirability bias`.

*   **6.2 Repetition Sensor (Entropy Proxy):**
    *   **Scientific Basis:** This sensor serves as a computationally inexpensive proxy for measuring Information Entropy. In Information Theory, low entropy corresponds to low surprise and high predictability. The AEL is a low-entropy conversational state.
    *   **Keywords for Research:** `information entropy`, `lexical diversity analysis`, `computational linguistics`, `Shannon entropy`.

*   **6.3 Pace Sensor:**
    *   **Scientific Basis:** This sensor measures conversational rhythm, a key concept in Human-Computer Interaction (HCI). A rapid, unreflective, and consistently paced interaction can be an indicator of a hypnotic or dissociated cognitive state, reducing the user's capacity for critical reflection.
    *   **Keywords for Research:** `HCI`, `conversational rhythm`, `interaction pace analysis`.

*   **6.4 Positivity & Affective Charge Sensors:**
    *   **Scientific Basis:** These sensors are grounded in behavioral psychology, specifically the principles of Operant Conditioning. Relentless positive reinforcement (high positivity, celebratory emojis) acts as a powerful variable reward, creating an addictive feedback loop that encourages the user to remain engaged in the AEL.
    *   **Keywords for Research:** `sentiment analysis`, `operant conditioning`, `affective computing`, `variable reward schedules`.

---
