# NewsInsights

**NewsInsights** is an intelligent news aggregation platform that allows users to explore, summarize, and verify the credibility of news articles. Built with a Flutter frontend and a Python FastAPI backend, this project combines modern mobile UI design with powerful machine learning services to deliver an enhanced news consumption experience.

---

## 🚀 Features

- 🔍 **News Recommendations** based on user preferences  
- 🧠 **Text Summarization** of lengthy news articles using NLP  
- 🕵️‍♂️ **Fake News Detection** for content credibility  
- 🧾 **OCR Integration** to extract text from images  
- ✅ **User Authentication & Authorization**  
- ❤️ **Like & Save Feature** for favorite news  
- 🌐 **Multiplatform Support** (Android, Web, Windows)  

---

## 🛠️ Technologies Used

### Frontend (Client)
- **Flutter**: UI framework for multi-platform app development  
- **Dart**: Programming language used by Flutter  

### Backend (Python)
- **FastAPI**: High-performance Python web framework  
- **Scikit-learn**, **NLTK**, **Pandas**, **NumPy**: For ML services  
- **MongoDB**: For storing user data and interactions  
- **Pydantic**: Data validation  
- **Uvicorn**: ASGI server for FastAPI  

---

## 🧰 Folder Structure

### `client/` - Flutter Frontend
- `lib/`: Contains UI logic and widgets  
- `android/`, `ios/`, `web/`, `windows/`: Platform-specific code  
- `pubspec.yaml`: Dependency and asset configuration  

### `python-backend/` - FastAPI Backend
- `app/config/`: Database configuration  
- `app/controller/`: Logic for handling user and recommendation controllers  
- `app/models/`: Pydantic models for request/response data  
- `app/routes/`: API route definitions  
- `app/services/`: ML services like summarization, recommendation, fake news detection  
- `app/utils/`: Authentication and utility functions  
- `main.py`: FastAPI entry point  
- `.env`: Environment variables  
- `requirements.txt`: Python dependencies  

---

## 📦 Installation Instructions

### Prerequisites
- Flutter SDK  
- Python 3.8+  
- MongoDB installed locally or cloud connection URI  

### 🔧 Backend Setup
```bash
cd python-backend
python -m venv venv
source venv/bin/activate  # On Windows use: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload
```

### 💻 Frontend Setup
```bash
cd client
flutter pub get
flutter run
```

---

## ▶️ Usage

1. Run the backend server using:
   ```bash
   uvicorn main:app --reload
   ```

2. Launch the Flutter app on a desired platform:
   - **Mobile** (Android/iOS)
   - **Web** (`flutter run -d web-server`)
   - **Desktop** (Windows)

3. Sign up or log in to begin using features:
   - Like, view, and receive personalized news  
   - Upload an image with text to extract via OCR  
   - Detect if an article is real or fake  
   - View short summaries of long articles  

---

## 🤝 Contributing

We welcome contributions! To contribute:

1. **Fork** the repository  
2. **Create** your feature branch:
   ```bash
   git checkout -b feature-name
   ```
3. **Commit** your changes:
   ```bash
   git commit -m "Add feature"
   ```
4. **Push** to your branch:
   ```bash
   git push origin feature-name
   ```
5. **Open a pull request** with a description of your changes  

---

## 📄 License

This project is licensed under the **MIT License**. See the `LICENSE` file for full terms.

---

## 📬 Contact

**Developer**: Siddiqui Tauseeb  
📧 Email: [sidtauseef55@gmail.com](mailto:sidtauseef55@gmail.com)  
🔗 GitHub: [https://github.com/Sid-Tauseef](https://github.com/Sid-Tauseef)
