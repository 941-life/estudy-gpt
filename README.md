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
- **Target Users:** Who wants to learn english

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


### Web Content & PDF Scraping with App Deep Linking Feature

- **Purpose:**  
  Allow users to scrape sentences (text) or PDF documents from a web browser and open them directly in the estudy_gpt app for AI-powered language learning.

- **How It Works:**  
  1. User selects text or a PDF file in the web browser.
  2. User clicks the "estudy_gpt" button (via share menu or deep link).
  3. The selected text or PDF is sent to the estudy_gpt app using a share intent or deep link.
  4. The app receives the content, detects its type, and extracts text if needed.
  5. The app displays language learning options.
  6. User selects an option and receives AI-generated feedback.

- **Screen/Flow:**  
  - Select text or PDF in browser → Share to estudy_gpt → App opens with shared content → Content type detected and text extracted → User selects analysis option → AI result displayed

- **Exception Handling:**  
  - No shared content: Show "No shared content found."
  - Invalid or empty input: Show error and prompt retry.
  - PDF/text extraction errors: Show error and allow retry.
  - API/network errors: Show error and allow retry.



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
  Enable seamless real-time messaging between a Flutter app and a React-based web application, allowing authenticated users to chat with a chatbot within the web interface. Securely synchronize user authentication data, transmit conversation data in real time, and provide a personalized chat experience.

- **How It Works:**
  - After a user logs in via the Flutter app, an authentication success message (`auth:success`) along with user information is sent to the web (WebView/iframe) via postMessage.
  - On the React web side, the useFlutterMessage(setUserData) hook listens for the window message event. When an authentication success message is received, the user information is saved to state.
  - Once authenticated user data is stored, the web chat component (ChatRoom) is activated, initializing the chat session and enabling real-time message exchange.
  - Messages entered by the user are processed on the web and, if necessary, sent to a server or AI chatbot API. Response messages are displayed in the chat interface.
  - Communication between Flutter and the web is bidirectional, using window.postMessage and window.addEventListener(`"message", ...`).

- **Screen/Flow:**
  - App Launch → Firebase Authentication (Flutter)
  - Upon successful authentication, Flutter sends user info to the web via postMessage
  - The web receives the authentication message with useFlutterMessage and stores user info
  - Once user info is set, the user enters the chat screen (ChatRoom)
  - User enters a message → Web sends the message to server/API/AI chatbot
  - Response message is received and displayed in the chat list in real time
  - (Optional) After chat ends, provide conversation analysis, feedback, or level adjustment features

- **Exception Handling:**
  - Unauthenticated State:
    - If the authentication message is not received or user info is missing, restrict access to the chat screen and display a login prompt or loading screen.

  - Message Reception Failure:
    - If the message format is invalid or a communication error occurs, display an error message and provide a retry option.

  - Network/Server Error:
    - If communication with the server or chatbot API fails, show an appropriate message and a retry button.

  - No Chat Data:
    - If there is no previous conversation history, display a message such as “No chat history found.”

  - Authorization/Security Issues:
    - If authentication data is forged or expired, terminate the session and redirect to the login screen.

  - Real-Time Sync Errors:
    - If message synchronization is delayed, display a loading indicator and notify the user of network status.

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
  Provide users with a motivational, interactive calendar experience that visually tracks their daily learning progress and achievements. The feature also delivers personalized motivational messages and enables users to quickly check or update their learning status directly from their device’s home screen via native widgets.

- **How It Works:** 
  - The main calendar UI is implemented in Flutter, displaying each month with daily statuses based on user activity (e.g., whether a wrong note was created on a given day).

  - When the user completes a daily task (such as creating a wrong note), the app determines if the task was completed and generates a motivational message using a static method (ChallengeCalendar.getMotivationalMessage).

  - The app uses the home_widget package to save relevant data (e.g., task completion status, motivational message, and current date) to shared storage accessible by native home screen widgets.

  - After saving the data, the app triggers a widget update using HomeWidget.updateWidget, ensuring that the home screen widget reflects the latest user progress and motivational message.

  - The widget can be initialized and configured to listen for user interactions, such as widget clicks, which can launch the app or perform other actions.

  - The home screen widget itself is implemented natively (SwiftUI for iOS, XML/Kotlin for Android), but receives its data from the Flutter app via the home_widget interface

- **Screen/Flow:**
  - App launch → Calendar screen displays monthly view with daily progress indicators.

  - User completes a daily learning task (e.g., creates a wrong note).

  - App calls ChallengeCalendarWidget.updateWidget to:

    - Generate a motivational message based on task completion.

    - Save the completion status, message, and current date via HomeWidget.saveWidgetData.

    - Trigger a widget update with HomeWidget.updateWidget.

  - Home screen widget displays the latest status and message.

  - (Optional) User taps the widget, which launches the app or navigates to the relevant calendar/task screen.
- **Exception Handling:**
  - Data Sync Issues:

    - If saving data to the widget fails (e.g., due to platform restrictions or storage errors), the app logs the error and can prompt the user to retry or check permissions.

  - Widget Update Failure:

    - If the widget fails to update (e.g., due to misconfigured provider names or missing native setup), the app logs the error for debugging and may show a notification to the user.

  - App Group/Permission Issues (iOS):

    - If setAppGroupId is not called or misconfigured, data sharing between the app and widget will fail. The app should check for and handle this case, possibly alerting the user to reinstall or update permissions.

  - No Task Completed:

    - If the user has not completed a daily task, the calendar and widget display an encouraging message to motivate the user to engage.

  - Widget Interaction Issues:

    - If the widget click event is not handled correctly, the app should log the URI and provide fallback navigation or feedback.

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
