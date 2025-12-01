# InterviewAce: AI-Powered Mock Interview & Preparation App 🚀

**InterviewAce** is a cutting-edge mobile application designed to revolutionize how candidates prepare for job interviews. Built with Flutter and powered by **Google Gemini AI**, it provides realistic mock interviews, real-time speech analysis, and personalized feedback to help users land their dream jobs.


## 📱 Features

### 🤖 AI-Powered Mock Interviews

  * **Realistic Interaction:** Engage in voice-based interviews with an AI interviewer.
  * **Text-to-Speech (TTS):** High-quality, lifelike voice responses powered by **ElevenLabs**.
  * **Speech-to-Text (STT):** Transcribes user responses in real-time for analysis.
  * **Visual Avatar:** Animated AI character that reacts when speaking.

### 📊 Real-Time Performance Analysis

  * **Speech Metrics:** Automatically calculates **Words Per Minute (WPM)**, **Filler Word Count** (um, uh, like), and **Clarity Score**.
  * **Emotion Detection:** Analyzes the sentiment and emotional tone of your responses.
  * **Detailed Feedback:** Provides constructive criticism on content, delivery, and confidence for every question.

### 🎯 Personalized Preparation

  * **Customizable Setup:** Choose your target **Job Role** (e.g., Cybersecurity, Software Engineer), **Difficulty Level** (Easy, Medium, Hard), and **Question Count**.
  * **Learn Hub:** Browse a database of interview questions and AI-generated solutions.
  * **Quizzes:** Test your knowledge with role-specific quizzes and earn badges (Bronze, Silver, Gold).

### 🎨 Modern UI/UX

  * **Glassmorphism Design:** A sleek, modern dark-mode aesthetic with blurred overlays and gradients.
  * **History Tracking:** Save and review past interview reports and performance trends.
  * **Profile Management:** Set career goals and manage your profile details.

-----

## 🛠️ Tech Stack

  * **Framework:** Flutter (Dart)
  * **State Management:** Provider
  * **Backend & Auth:** Firebase Authentication, Cloud Firestore, Firebase Storage
  * **AI Engine:** Google Gemini API (gemini-2.0-flash)
  * **Voice Synthesis:** ElevenLabs API
  * **Speech Recognition:** `speech_to_text` package
  * **Architecture:** Clean Architecture (Services, Providers, Models, Screens)

-----

## 📸 Screenshots

| Home Dashboard | Interview Setup | Active Interview | Detailed Report |
|:---:|:---:|:---:|:---:|
| | | | |
| *Glassmorphic Dashboard* | *Custom Configuration* | *AI Interaction* | *Performance Analysis* |

-----

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites

  * [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
  * A Firebase Project.
  * API Keys for **Google Gemini** and **ElevenLabs**.

### Installation

1.  **Clone the Repository**

    ```bash
    git clone https://github.com/YourUsername/interviewace.git
    cd interviewace
    ```

2.  **Install Dependencies**

    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**

      * Install the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/).
      * Run the configuration command in your terminal:
        ```bash
        flutterfire configure
        ```
      * This will generate `lib/firebase_options.dart`.

4.  **Configure API Keys**
    Open `lib/core/constants/app_constants.dart` and add your API keys:

    ```dart
    class AppConstants {
      // ... existing code ...

      // Add your Google Gemini API Key
      static const String geminiApiKey = 'YOUR_GEMINI_API_KEY'; 
      
      // Add your ElevenLabs API Key
      static const String elevenLabsApiKey = "YOUR_ELEVENLABS_API_KEY";

      // ... existing code ...
    }
    ```

5.  **Run the App**

    ```bash
    flutter run
    ```

-----

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants (Colors, Strings, Keys)
│   ├── services/        # API, Auth, Storage, TTS services
│   ├── theme/           # AppTheme and Glassmorphism styles
│   └── utils/           # Helpers and Validators
├── data/                # Static data (Questions, Quiz data)
├── models/              # Data models (User, Interview, Question)
├── providers/           # State management (AuthProvider, InterviewProvider)
├── screens/             # UI Screens (Home, Interview, Report, Auth)
├── services/            # Business logic (AI Service, Report Service)
├── widgets/             # Reusable UI components
└── main.dart            # Entry point
```

-----

## 🤝 Contributing

Contributions are welcome\! If you have suggestions for improvements or new features, please follow these steps:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/YourFeature`).
3.  Commit your changes (`git commit -m 'Add some feature'`).
4.  Push to the branch (`git push origin feature/YourFeature`).
5.  Open a Pull Request.

-----

## 🛡️ License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.

-----

## 👨‍💻 Developers

  * **Akash Chakresh** - *Lead Developer*
  * **Roshan Chaudhary** - *Junior Developer*

-----

\<p align="center"\>
Built with ❤️ using Flutter and AI
\</p\>
