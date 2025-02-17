AttendMe - User Manual

Introduction

AttendMe is an automated facial recognition-based attendance management system designed for educational institutions and workplaces. The system uses real-time face detection and recognition to mark attendance accurately and efficiently.

Features

Facial Recognition: Uses AI-based models to identify and authenticate students and employees.

User Authentication: Secure login and registration for students and teachers.

Attendance Management: Automatically records attendance based on recognized faces.

Database Management: Stores user data, attendance records, and images securely.

REST API Integration: Provides API endpoints for integration with mobile and web applications.

System Requirements

Backend (Django)

Python 3.10+

Django 5.0+

PostgreSQL / SQLite (recommended for development)

Required libraries (install using requirements.txt)

Frontend (Flutter)

Flutter SDK 3.0+

Dart 2.18+

Android Studio / VS Code

Additional Dependencies

OpenCV (for facial detection & recognition)

MTCNN & FaceNet for feature extraction

Joblib for model loading

Installation

Backend Setup (Django)

Clone the repository:

git clone https://github.com/your-repo/AttendMe.git
cd AttendMe/backend

Create and activate a virtual environment:

python -m venv venv
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows

Install dependencies:

pip install -r requirements.txt

Apply migrations:

python manage.py migrate

Start the server:

python manage.py runserver

Frontend Setup (Flutter)

Navigate to the frontend directory:

cd ../frontend

Install dependencies:

flutter pub get

Run the application:

flutter run

Usage

Registering a User

Open the AttendMe app.

Select "Sign Up" and enter your details.

Capture facial images as prompted.

Submit the form to complete registration.

Logging In

Open the AttendMe app.

Enter your email and password.

Click "Login" to access your dashboard.

Marking Attendance

Navigate to the attendance screen.

Allow camera access for face recognition.

The system will recognize your face and mark attendance automatically.

Attendance records can be viewed in the dashboard.

API Endpoints

User Authentication: /api/auth/login/, /api/auth/register/

Attendance Management: /api/attendance/mark/, /api/attendance/history/

User Profile: /api/users/profile/

Troubleshooting

Common Issues and Solutions

Face Not Recognized: Ensure good lighting and a clear background.

Login Issues: Verify credentials or reset the password.

Camera Not Working: Check app permissions and restart the device.
