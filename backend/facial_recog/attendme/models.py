from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager

class Teacher(AbstractBaseUser):
    teacher_id = models.CharField(max_length=100, unique=True)
    password = models.CharField(max_length=100)

    USERNAME_FIELD = 'teacher_id'


class UserManager(BaseUserManager):
    def create_user(self, student_id, password=None, **extra_fields):
        if not student_id:
            raise ValueError('The Student ID field must be set')
        user = self.model(student_id=student_id, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, student_id, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        return self.create_user(student_id, password, **extra_fields)

class Student(AbstractBaseUser):
    student_id = models.CharField(max_length=100, unique=True)
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    batch = models.CharField(max_length=100)
    enrolled_year = models.CharField(max_length=4)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=100)
    registered_on = models.DateTimeField(auto_now_add=True)

    USERNAME_FIELD = 'student_id'
    REQUIRED_FIELDS = ['email']

    objects = UserManager()

    def __str__(self):
        return self.student_id

class StudentImage(models.Model):
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    image = models.ImageField(upload_to='student_images/')
    angle = models.CharField(max_length=10)

    def __str__(self):
        return f'{self.student.student_id} - {self.angle}'
