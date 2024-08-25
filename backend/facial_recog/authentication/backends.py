from django.contrib.auth.backends import ModelBackend
from .models import Student

class StudentIDAuthBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        try:
            student = Student.objects.get(student_id=username)
            if student.check_password(password):
                return student
        except Student.DoesNotExist:
            return None
