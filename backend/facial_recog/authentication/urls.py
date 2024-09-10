from django.urls import path
from .views import (
    StudentRegistrationView,
    TeacherRegistrationView,
    StudentLoginView,
    TeacherLoginView,
    StudentProfileView,
    StudentListAPI,
    TeacherProfileView,
    TeacherListAPI,
    UserChangePasswordView,
    SendPasswordResetEmailView,
    UserPasswordResetView,
    UploadPhotoView,
    # ImagePredictView
    ImageRecognition
)

urlpatterns = [
    # Student URLs
    path('student/', StudentListAPI.as_view(), name='student_list_api'),
    path('student/register/', StudentRegistrationView.as_view(), name='student-register'),
    path('student/login/', StudentLoginView.as_view(), name='student-login'),
    path('student/profile/', StudentProfileView.as_view(), name='student-profile'),
    path('upload_photo/', UploadPhotoView.as_view(), name='upload_photo'),

    # Teacher URLs
    path('teacher/', TeacherListAPI.as_view(), name='teacher_list_api'),
    path('teacher/register/', TeacherRegistrationView.as_view(), name='teacher-register'),
    path('teacher/login/', TeacherLoginView.as_view(), name='teacher-login'),
    path('teacher/profile/', TeacherProfileView.as_view(), name='teacher-profile'),
    # path('predict-image/', ImagePredictView.as_view(), name='predict_image'),
     path('predict/', ImageRecognition.as_view(), name='image_recognition'),

    # Common URLs
    path('changepassword/', UserChangePasswordView.as_view(), name='change-password'),
    path('send-reset-password-email/', SendPasswordResetEmailView.as_view(), name='send-reset-password-email'),
    path('reset-password/<uid>/<token>/', UserPasswordResetView.as_view(), name='reset-password'),
]


    