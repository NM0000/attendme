from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TeacherViewSet, StudentViewSet, StudentImageViewSet



router = DefaultRouter()
router.register(r'teachers', TeacherViewSet, basename='teacher')

urlpatterns = [
    path('', include(router.urls)),
]

router = DefaultRouter()
router.register(r'students', StudentViewSet)
router.register(r'student_images', StudentImageViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
