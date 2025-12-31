# Velo: Personal Fitness Plan Organizer

Velo is a modern, privacy-first, offline-capable fitness application built with Flutter. It empowers you to create custom exercises, plan detailed weekly schedules, and perform guided workouts with ease.

## 🚀 Features

### 🏋️ Exercise Library Management
*   **Custom Exercises**: Create your own exercises with detailed instructions, target muscle groups, and difficulty levels.
*   **Media Support**: Add GIFs or Videos to your exercises via URL. The app automatically caches media for offline use ("load once, keep forever").
*   **Search & Filter**: Quickly find exercises by name or filter them by Body Part, Difficulty, or Type.

### 📅 Workout Planning & Scheduling
*   **Weekly Schedule Builder**: A sleek, Material You-style weekly calendar view.
*   **Detailed Configuration**: Assign exercises to specific days with custom targets for **Sets**, **Reps**, and **Time**.
*   **Drag-and-Drop**: Easily reorder exercises within a day to perfect your workout flow.
*   **Smart Scheduling**: Create multiple schedules (backend ready) and manage your weekly routine efficiently.

### ▶️ Follow-Along Workout Mode
*   **Guided Session**: Start your scheduled workout directly from the "Today" tab.
*   **Smart Timers**:
    *   **Active Timer (Green)**: Counts up elapsed time for rep-based exercises, or counts down for time-based exercises (e.g., Planks).
    *   **Rest Timer (Orange)**: Automatically starts a countdown between sets.
*   **Visual Guidance**: See exercise media (GIFs/Videos) and instructions while you workout. Media remains visible during rest for continuity.
*   **Smart Flow**: Automatically skips the "Rest" step after the final set of the last exercise.

### 🎨 Modern UI/UX
*   **Material You Design**: Fully embraces Material 3 guidelines with adaptive colors and rounded components.
*   **Dark Mode**: Built-in Dark Mode support with a convenient toggle on the home screen.
*   **Polished Experience**: Smooth animations, clean layouts, and intuitive navigation.

## 🛠️ Tech Stack

*   **Framework**: Flutter (Dart)
*   **State Management**: Riverpod
*   **Local Database**: SQLite (sqflite)
*   **Media Caching**: cached_network_image
*   **Architecture**: Clean Architecture (Domain, Data, Presentation layers)

## 📱 Getting Started

### Prerequisites
*   Flutter SDK installed ([Installation Guide](https://flutter.dev/docs/get-started/install))
*   Android Studio or Xcode for mobile development

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/solidate/Velo.git
    cd Velo
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the code generator** (if you make changes to providers):
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

## 📸 Usage

1.  **Create Exercises**: Go to the **Exercises** tab and tap **+** to add your custom exercises. Paste a GIF URL to see it animate!
2.  **Plan Your Week**: Go to the **Schedule** tab. Select a day (e.g., Monday) and tap **+** to add exercises. Configure your Sets, Reps, and optional Time.
3.  **Start Working Out**: Go to the **Today** tab. If you have a workout scheduled for today, tap **Start Workout** to begin your guided session.

## 📄 License

This project is licensed under the MIT License.
