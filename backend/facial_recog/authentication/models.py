from django.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager

class CustomUserManager(BaseUserManager):
    def create_user(self, student_id=None, teacher_id=None, first_name=None, last_name=None, email=None, batch=None, enrolled_year=None, password=None, **extra_fields):
        if student_id:
            if not student_id:
                raise ValueError("The Student ID must be set")
            if email:
                email = self.normalize_email(email)

            user = self.model(student_id=student_id, first_name=first_name, last_name=last_name, email=email, batch=batch, enrolled_year=enrolled_year, **extra_fields)
            user.set_password(password)
            user.save(using=self._db)
            return user

        elif teacher_id:
            user = self.model(teacher_id=teacher_id, first_name=first_name, last_name=last_name, **extra_fields)
            user.set_password(password)
            user.save(using=self._db)
            return user
        else:
            raise ValueError("Either Student ID or Teacher ID must be set")

            
class Student(AbstractBaseUser):
    student_id = models.CharField(max_length=50, unique=True)
    password = models.CharField(max_length=128)
    email = models.EmailField(unique=True)
    batch = models.CharField(max_length=50)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    enrolled_year = models.IntegerField()
    # recognized_faces = models.JSONField(default=list)  # Storing JSON-encoded data
   
    date_joined = models.DateTimeField(default=timezone.now)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    objects = CustomUserManager()

    USERNAME_FIELD = 'student_id'
    REQUIRED_FIELDS = ['email', 'first_name', 'last_name', 'batch', 'enrolled_year']

    def __str__(self):
        return self.student_id

    def has_perm(self, perm, obj=None):
        return self.is_superuser

    def has_module_perm(self, app_label):
        return True

class Teacher(AbstractBaseUser):
    teacher_id = models.CharField(max_length=50, unique=True)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    date_joined = models.DateTimeField(default=timezone.now)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=True)
    is_superuser = models.BooleanField(default=False)

    objects = CustomUserManager()

    USERNAME_FIELD = 'teacher_id'
    REQUIRED_FIELDS = ['first_name', 'last_name']

    class Meta:
        verbose_name = ('teacher')
        verbose_name_plural = ('teachers')

    def __str__(self):
        return self.teacher_id

    def has_perm(self, perm, obj=None):
        return self.is_superuser

    def has_module_perms(self, app_label):
        return True

