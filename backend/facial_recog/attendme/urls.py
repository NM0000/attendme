# from django.urls import path
# from .views import TeacherCreateView, StudentCreateView

# urlpatterns = [
#     path('teacher/register/', TeacherCreateView.as_view(), name='teacher-register'),
#     path('student/register/', StudentCreateView.as_view(), name='student-register'),
# ]

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TeacherViewSet, StudentViewSet, StudentImageViewSet

router = DefaultRouter()
router.register(r'teachers', TeacherViewSet)

urlpatterns = [
    path('', include(router.urls)),
]


router = DefaultRouter()
router.register(r'students', StudentViewSet)
router.register(r'student_images', StudentImageViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
