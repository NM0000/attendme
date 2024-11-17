from django.conf import settings
from django.conf.urls.static import static
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
    UploadImagesAPIView,
    RealTimeFaceRecognitionView,
    AttendanceListCreateView, 
    AttendanceRetrieveUpdateView,
    AttendanceDetailView,
)

urlpatterns = [
    # Student URLs
    path('student/', StudentListAPI.as_view(), name='student_list_api'),
    path('student/register/', StudentRegistrationView.as_view(), name='student-register'),
    path('student/login/', StudentLoginView.as_view(), name='student-login'),
    path('student/profile/', StudentProfileView.as_view(), name='student-profile'),
    path('upload_images/', UploadImagesAPIView.as_view(), name='upload_image'),
    path('recognize-face/', RealTimeFaceRecognitionView.as_view(), name='recognize_face'),

    # Teacher URLs
    path('teacher/', TeacherListAPI.as_view(), name='teacher_list_api'),
    path('teacher/register/', TeacherRegistrationView.as_view(), name='teacher-register'),
    path('teacher/login/', TeacherLoginView.as_view(), name='teacher-login'),
    path('teacher/profile/', TeacherProfileView.as_view(), name='teacher-profile'),


    # Common URLs
    path('changepassword/', UserChangePasswordView.as_view(), name='change-password'),
    path('send-reset-password-email/', SendPasswordResetEmailView.as_view(), name='send-reset-password-email'),
    path('reset-password/<uid>/<token>/', UserPasswordResetView.as_view(), name='reset-password'),

    #Attendance URLs
    # List all attendance records or create new ones
    path('attendance/', AttendanceListCreateView.as_view(), name='attendance_list_create'),
    # Retrieve or update attendance by student ID
    path('attendance/<str:student_id>/', AttendanceRetrieveUpdateView.as_view(), name='attendance_retrieve_update'),
    # Read-only fetch of attendance for a specific student
    path('attendance/detail/<str:student_id>/', AttendanceDetailView.as_view(), name='attendance_detail'),

]
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

    