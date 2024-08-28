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
            if not teacher_id:
                raise ValueError("The Teacher ID must be set")
            if email:
                email = self.normalize_email(email)
            user = self.model(teacher_id=teacher_id, first_name=first_name, last_name=last_name, email=email, **extra_fields)
            user.set_password(password)
            user.save(using=self._db)
            return user
        else:
            raise ValueError("Either Student ID or Teacher ID must be set")
    
    def create_superuser(self, teacher_id, first_name, last_name, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(teacher_id=teacher_id, first_name=first_name, last_name=last_name, email=email, password=password, **extra_fields)

class Student(AbstractBaseUser):
    student_id = models.CharField(max_length=50, unique=True)
    email = models.EmailField(unique=True)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    batch = models.CharField(max_length=50)
    enrolled_year = models.IntegerField()
    # recognized_faces = models.JSONField(default=list)  # Storing JSON-encoded data
    password = models.CharField(max_length=128)
   
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

    def has_module_perms(self, app_label):
        return True

class Teacher(AbstractBaseUser):
    teacher_id = models.CharField(max_length=50, unique=True)
    email = models.EmailField(unique=True)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    password = models.CharField(max_length=128)
    
    date_joined = models.DateTimeField(default=timezone.now)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    objects = CustomUserManager()

    USERNAME_FIELD = 'teacher_id'
    REQUIRED_FIELDS = ['email', 'first_name', 'last_name']

    class Meta:
        verbose_name = 'teacher'
        verbose_name_plural = 'teachers'

    def __str__(self):
        return self.teacher_id

    def has_perm(self, perm, obj=None):
        return self.is_superuser

    def has_module_perms(self, app_label):
        return True


class StudentImage(models.Model):
    student_id = models.CharField(max_length=100)
    image = models.ImageField(upload_to='images/')
    created_at = models.DateTimeField(auto_now_add=True)