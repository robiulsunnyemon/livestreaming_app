# InstaLive 🎥

InstaLive is a robust and feature-rich live streaming application built with Flutter. It offers a seamless platform for content creators and viewers to connect in real-time, featuring high-quality video streaming, interactive chat, and integrated monetization tools.

## 🚀 Key Features

*   **🎙️ Live Streaming:** High-quality, low-latency live broadcasting powered by **LiveKit** and **WebRTC**.
*   **💬 Real-time Chat:** Interactive chat system for instant engagement between streamers and viewers.
*   **📞 Audio & Video Calls:** dedicated module for direct audio and video communication.
*   **💰 Monetization & Wallet:** Integrated **Stripe** payments for donations/subscriptions, with a comprehensive wallet system to track earnings and transaction history (`finance`, `payment_history`).
*   **🔐 Authentication:** Secure user authentication using **Google Sign-In** and **Firebase**.
*   **🛡️ KYC Verification:** Built-in Identity Verification (Know Your Customer) module for broadcaster validation.
*   **🌍 Explore & Discover:** Dashboard and Explore sections to find trending streams and new content creators.
*   **🔔 Notifications:** Push notification system to keep users updated.
*   **👤 User Profiles:** Detailed user profiles (`profile`, `public_profile`) with social features.

## 🛠 Tech Stack

*   **Framework:** [Flutter](https://flutter.dev/)
*   **Language:** [Dart](https://dart.dev/)
*   **State Management:** [GetX](https://pub.dev/packages/get)
*   **Streaming Engine:** [LiveKit](https://livekit.io/) & [WebRTC](https://webrtc.org/)
*   **Backend Services:**
    *   **Firebase** (Authentication, Core)
    *   **Stripe** (Payments)
*   **Architecture:** MVC (Model-View-Controller) with GetX pattern.

## 📦 Dependencies

Major packages used in this project include:

*   `get`: State management and route management.
*   `livekit_client`: For live audio/video streaming.
*   `flutter_webrtc`: WebRTC support for Flutter.
*   `flutter_stripe`: Stripe payment integration.
*   `google_sign_in` & `firebase_core`: Authentication services.
*   `web_socket_channel`: WebSocket connections.
*   `image_picker`: Media selection.
*   `intl`: Internationalization and formatting.
*   `permission_handler`: Managing app permissions.

## ⚙️ Installation & Setup

To run this project locally, follow these steps:

1.  **Prerequisites:**
    *   Flutter SDK (version `^3.10.1` as per `pubspec.yaml`)
    *   Dart SDK

2.  **Clone the Repository:**
    ```bash
    git clone https://github.com/your-repo/erron_live_app.git
    cd erron_live_app
    ```

3.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Configuration:**
    *   **Firebase:** Place your `google-services.json` (for Android) in `android/app/` and `GoogleService-Info.plist` (for iOS) in `ios/Runner/`.
    *   **Stripe:** Configure your Stripe Publishable Key in the app constants/settings.
    *   **LiveKit:** Ensure your LiveKit server URL and API keys are correctly set up in the environment/constants file.

5.  **Run the App:**
    ```bash
    flutter run
    ```

## 📂 Project Structure

This project uses the standard **GetX** structure for scalability and maintainability:

```
lib/
├── app/
│   ├── core/               # Utilities, Constants, Themes
│   ├── data/               # Data Layer (Models, Services, Providers)
│   ├── modules/            # Feature Modules (GetX Architecture)
│   │   ├── auth/           
│   │   │   ├── bindings/   
│   │   │   │   └── auth_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── auth_controller.dart
│   │   │   └── views/      
│   │   │       ├── login_view.dart
│   │   │       ├── register_view.dart
│   │   │       ├── otp_view.dart
│   │   │       ├── forgot_password_view.dart
│   │   │       └── reset_password_view.dart
│   │   ├── call/           
│   │   │   ├── bindings/
│   │   │   │   └── call_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── call_controller.dart
│   │   │   └── views/
│   │   │       ├── call_view.dart
│   │   │       └── texture_video_renderer.dart
│   │   ├── chat/           
│   │   │   ├── bindings/
│   │   │   │   └── chat_binding.dart
│   │   │   ├── controllers/
│   │   │   │   ├── chat_controller.dart
│   │   │   │   └── active_users_controller.dart
│   │   │   └── views/
│   │   │       ├── chat_view.dart
│   │   │       └── active_users_view.dart
│   │   ├── dashboard/      
│   │   │   ├── bindings/
│   │   │   │   └── dashboard_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── dashboard_controller.dart
│   │   │   └── views/
│   │   │       └── dashboard_view.dart
│   │   ├── explore/        
│   │   │   ├── bindings/
│   │   │   │   └── explore_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── explore_controller.dart
│   │   │   └── views/
│   │   │       └── explore_view.dart
│   │   ├── finance/        
│   │   │   ├── bindings/
│   │   │   │   └── finance_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── finance_controller.dart
│   │   │   └── views/
│   │   │       ├── link_account_view.dart
│   │   │       ├── payout_success_view.dart
│   │   │       ├── withdraw_amount_view.dart
│   │   │       └── withdraw_to_view.dart
│   │   ├── home/           
│   │   │   ├── bindings/
│   │   │   │   └── home_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── home_controller.dart
│   │   │   └── views/
│   │   │       └── home_view.dart
│   │   ├── kyc/            
│   │   │   ├── bindings/
│   │   │   │   └── kyc_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── kyc_controller.dart
│   │   │   └── views/
│   │   │       └── kyc_view.dart
│   │   ├── live_streaming/ 
│   │   │   ├── bindings/
│   │   │   │   └── live_streaming_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── live_streaming_controller.dart
│   │   │   └── views/
│   │   │       ├── live_streaming_view.dart
│   │   │       └── stream_review_dialog.dart
│   │   ├── notifications/  
│   │   │   ├── bindings/
│   │   │   │   └── notification_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── notification_controller.dart
│   │   │   └── views/
│   │   │       └── notification_view.dart
│   │   ├── payment_history/
│   │   │   ├── bindings/
│   │   │   │   └── payment_history_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── payment_history_controller.dart
│   │   │   └── views/
│   │   │       └── payment_history_view.dart
│   │   ├── profile/        
│   │   │   ├── bindings/
│   │   │   │   ├── profile_binding.dart
│   │   │   │   └── edit_profile_binding.dart
│   │   │   ├── controllers/
│   │   │   │   ├── profile_controller.dart
│   │   │   │   └── edit_profile_controller.dart
│   │   │   └── views/
│   │   │       ├── profile_view.dart
│   │   │       └── edit_profile_view.dart
│   │   ├── public_profile/ 
│   │   │   ├── bindings/
│   │   │   │   └── public_profile_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── public_profile_controller.dart
│   │   │   └── views/
│   │   │       └── public_profile_view.dart
│   │   ├── start_live/     
│   │   │   ├── bindings/
│   │   │   │   └── start_live_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── start_live_controller.dart
│   │   │   └── views/
│   │   │       └── start_live_view.dart
│   │   └── welcome/        
│   │       ├── bindings/
│   │       │   └── welcome_binding.dart
│   │       ├── controllers/
│   │       │   └── welcome_controller.dart
│   │       └── views/
│   │           └── welcome_view.dart
│   └── routes/             # App Navigation & Page Routes
└── main.dart               # Entry Point
```

## 🤝 Contributing

Contributions are welcome! If you find a bug or want to add a feature, please open an issue or submit a pull request.

---
*Developed  by robiulsunnyemon.*
