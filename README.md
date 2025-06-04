# App Development Technical Documentation

## Table of Contents Example

1. [Overview](#1-overview)
2. [System Architecture](#2-system-architecture)
3. [Feature Details](#3-feature-details)
4. [Data Structure](#4-data-structure)
5. [UI/UX Design](#5-uiux-design)
6. [API Documentation](#6-api-documentation)
7. [Setup & Deployment](#7-setup--deployment)
8. [Testing](#8-testing)
9. [Maintenance & Reference](#9-maintenance--reference)

## 1. Overview

- **App Name:** eStudy GPT
- **Version:** 1.0.0
- **Summary of Purpose and Key Features:** Personalized, real-world language learning app
- **Target Users:**

## 2. System Architecture

- **Overall Architecture Diagram:** (Image/Link)
- **Technology Stack:**
  - Language:
    - Flutter: Dart
    - React: JavaScript/TypeScript
  - Framework:
    - Flutter
    - React
  - Library:
    - Firebae SDKs (Authenication, Firestore, Realtimbe Database)
    - Google Genrative AI SDK (Gemini API)
  - Database:
    - Firebase Firestore (NoSQL, real-time database)
  - Others:
    - Firebase Authenication (user management)
    - Google Gemini API (generative AI features)
- **Third-party Integration:**
  - **Firebase:**
    - Used for authenication, real-time databas (Firestore), ananlytics, and other backend services for both Flutter and React
  - **Google Gemini API:**
    - Integrated for generative AI features such as text generation, chatbots, content summarization, etc.
    - Accessed via REST API or Google Generative AI SDK, with secure API key management

## 3. Feature Details

### Login

- **Purpose:**
  Allows users to sign in using Google account for personalized access

- **How It Works:**

  1. User click `Sign in with Google` button to login with Google account
  2. Credentials are sent to Firebase Authentication
  3. If authentication is successful, user data and token are returned
  4. On failure, error message is shown

- **Screen/Flow:**
  - Login Screen -> Home Screen
  - `Sign in with Google` button triggers Google login popup
  - On success, navigate to Home Screen
  - On failure, display error message
- **Exception Handling:**
  - Invalid credentials: Show "Check your account again."
  - Network failure: Show "Please check your internet connection."
  - Server error: Log error and show generic error message

### WebView-React Bridge & User Authentication Data Sync

- **Purpose:**
  Enable seamless communication between Flutter app (using WebView) and React-based web app. Specifically, authenticate the user in Flutter (Firebase Auth) and securely pass user information (email, display name, photo, access token, uuid) to React app running inside WebView. Also, handle navigation and content scraping messages from web app.

- **How It Works:**

  1. Flutter app authenticates the user using Firebase Auth
  2. Upon loading the WebView, Flutter injects the authenticated user's data into the React web app using JavaScript (`window.postMessage`)
  3. WebView listens for messages from web app via JavaScript channel (`FlutterBridge`):

     - If the message type is `router:push`, WebView navigates to specified path

  4. When the page finishes loading, the user data is sent again to ensure synchronization
  5. The WebView also fetches the page title and expose it via a callback for UI updates

- **Screen/Flow:**
  - User logs in via Flutter (`Firebase Auth`)
  - WebView loads the initial URL (React web app)
  - On page load, user data is posted to the React app
  - React app can request navigation or send content back to Flutter via `window.postMessage` (handled by the Flutter JavaScript channel)
  - App responds to navigation or content scraping requests as needed
  - The page title is optionally updated in Flutter UI via the `onTitleChanged` callback
- **Exception Handling:**
  - If user info or access token is unavailable, no data is sent to React
  - Any unhandled message types from the web app are logged using `debugPrint`
  - If navigation fails (e.g., invalid path), the error is not propagated to the user but can be logged for debugging
  - Network or authentication errors are managed by the Firebase Auth flow and surfaced to the user as appropriate

### Chatting

- **Purpose:**

- **How It Works:**


- **Screen/Flow:**
- **Exception Handling:**

### Wrong Note Screen (Firebase-based User Wrong Notes)

- **Purpose:**  
  Allow users to view their personalized wrong note records, fetched from Firebase Firestore, within the Flutter app after authentication.

- **How It Works:**

  1. User logs in via Firebase Authentication.
  2. The app fetches the user's wrong note data from Firestore using their UID or email.
  3. Wrong notes are displayed in a list using a real-time stream or one-time fetch.
  4. Each note shows details such as question, user's answer, correct answer, explanation, and date.

- **Screen/Flow:**

  - App start → Login/Sign up → Navigate to Wrong Note screen
  - Fetch wrong note data from Firestore
  - Display list of wrong notes
  - Tap on a note to view details
  - (Optional) Add, edit, or delete notes

- **Exception Handling:**
  - If not logged in, redirect to login screen.
  - If Firestore fetch fails, show error message or retry option.
  - If no notes exist, display a “No wrong notes found” message.
  - Show loading indicator or error message if network issues occur.

### Calendar

- **Purpose:**

- **How It Works:**


- **Screen/Flow:**
- **Exception Handling:**

## 4. Data Structure

- **DB Design (ERD, Table Structure):**

  - Firestore structure:

    ```
    users (Collection)
    └─ {userId} (Document)
       └─ wrongNotes (Collection)
            └─ {wrongNoteId} (Document)
                 ├─ question: string
                 ├─ answer: string
                 ├─ userAnswer: string
                 ├─ createdAt: timestamp
                 ├─ updatedAt: timestamp
                 └─ tags: [string]

    ```

- **Main Data Models and Attributes:**

  | Field      | Type          | Description    |
  | :--------- | :------------ | :------------- |
  | question   | string        | The content of the question |
  | answer     | string        | The correct answer|
  | userAnswer | string        | The user's submitted answer|
  | cratedAt   | timestamp     | Creation timestamp|
  | updatedAt  | timestamp     | Last updated timestamp|
  | tags       | array[string] | Tags (optional)|

- **API Specifications (Input/Output Data Format):**
  - Created/Update Input Example
    ```
    {
      "question": "What is the capital of France?",
      "answer": "Paris",
      "userAnswer": "Lyon",
      "createdAt": "2025-06-03T06:00:00.000Z",
      "updatedAt": "2025-06-03T06:00:00.000Z",
      "tags": ["geography", "europe"]
    }

    ```
  - Read Output Example
    ```
    [
      {
        "wrongNoteId": "abc123",
        "question": "What is the capital of France?",
        "answer": "Paris",
        "userAnswer": "Lyon",
        "createdAt": "2025-06-03T06:00:00.000Z",
        "updatedAt": "2025-06-03T06:00:00.000Z",
        "tags": ["geography", "europe"]
      }
    ]
    ```


## 5. UI/UX Design

- **List of Screens and Flowchart:**
- **Detailed Description for Each Screen:**
- **Wireframes/Design Mockups:** (Image/Link)

## 6. API Documentation

- **List of Endpoints:**
- **Request/Response Examples:**
- **Error Codes and Handling:**

## 7. Setup & Deployment

- **Development Environment Setup:**
- **Build and Deployment Procedures:**
- **Environment Variables/Configuration Files:**

## 8. Testing

- **Test Items and Methods:**
- **Test Case Examples:**
- **Automated Test Tools and Scripts:**

## 9. Maintenance & Reference

- **Common Issues and Solutions:**
- **Reference Documents/Links:**
- **Future Improvements:**

---
