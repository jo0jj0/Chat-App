# Chat-App

## Description

This chat application is a feature-rich communication platform designed for modern user interaction. It includes functionalities such as user account management, text and media messaging, audio and video calls, and various chat modifications like hiding or deleting chats and messages. The backend is powered by Firebase, ensuring real-time updates and scalable data handling, while security is enhanced through robust encryption for all text messages.

## Technical Overview

### User Interface:

- Developed entirely using SwiftUI, providing a responsive and modern design.
- Utilized various SwiftUI components such as ZStack, HStack, VStack, NavigationStack for layout management.
- Implemented custom UI elements like a TabBar with a floating button and an animated background.

### Architecture:

- Followed the MVVM (Model-View-ViewModel) pattern to separate concerns, improve code maintainability, and enhance application performance.

### Firebase Integration:

#### Authentication (FirebaseAuth):

      - Implemented user registration and login with email and password.
      - Email verification through a verification link.
      - Password reset functionality via email.
      - User account deletion.

#### Firestore:
      - Chosen for its scalability and capability to handle complex queries, making it ideal for real-time chat applications.
      - Used async functions for reading data and listeners for real-time updates to keep the application state synchronized.

#### Storage:

      - Utilized for storing media files including profile photos, conversation photos, and audio files.
      - Ensured efficient media management and retrieval within the app.

### Call Functionality:

- Integrated GetStream framework to handle audio and video calls.
- Managed call logic by creating and joining calls between users using stored keys from the database.
- The first participant initiates the call, and the second participant can join, leveraging functions provided by the GetStream framework.

### Message Encryption:

- Utilized CryptoSwift for encrypting and decrypting text messages.
- Generated a random 32-bit key for each chat, stored securely in the database.
- Used the key to encrypt messages before writing to the database and decrypt them upon reading, ensuring message confidentiality.

### Real-time Updates:

- Implemented listeners in Firestore to receive real-time updates on chat messages and user statuses.
- Used async/await patterns to handle asynchronous data fetching, improving the responsiveness of the application.

### Additional Functionalities:

#### Chat Modifications:

      - Implemented features for hiding and deleting chats and messages, providing users with control over their chat history.

#### Media Messages:

      - Supported sending and receiving images, audio files, and other media types within the chat.

#### User Profiles:

      - Enabled users to upload and update profile pictures and name, enhancing personalization within the app.
