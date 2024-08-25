from django.urls import path
from .views import (
    StudentRegistrationView,
    TeacherRegistrationView,
    StudentLoginView,
    TeacherLoginView,
    StudentProfileView,
    TeacherProfileView,
    UserChangePasswordView,
    SendPasswordResetEmailView,
    UserPasswordResetView
)

urlpatterns = [
    # Student URLs
    path('student/register/', StudentRegistrationView.as_view(), name='student-register'),
    path('student/login/', StudentLoginView.as_view(), name='student-login'),
    path('student/profile/', StudentProfileView.as_view(), name='student-profile'),

    # Teacher URLs
    path('teacher/register/', TeacherRegistrationView.as_view(), name='teacher-register'),
    path('teacher/login/', TeacherLoginView.as_view(), name='teacher-login'),
    path('teacher/profile/', TeacherProfileView.as_view(), name='teacher-profile'),

    # Common URLs
    path('changepassword/', UserChangePasswordView.as_view(), name='change-password'),
    path('send-reset-password-email/', SendPasswordResetEmailView.as_view(), name='send-reset-password-email'),
    path('reset-password/<uid>/<token>/', UserPasswordResetView.as_view(), name='reset-password'),
]



# from django.urls import path
# from .views import StudentRegisterView, TeacherRegisterView, LoginView

# urlpatterns = [
#     path('admin/', admin.site.urls),
#     path('student/register/', StudentRegisterView.as_view(), name='student-register'),
#     path('teacher/register/', TeacherRegisterView.as_view(), name='teacher-register'),
#     path('login/', LoginView.as_view(), name='login'),
# ]
