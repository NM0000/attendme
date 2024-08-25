from rest_framework import serializers
from django.utils.encoding import smart_str, force_bytes, DjangoUnicodeDecodeError
from django.utils.http import urlsafe_base64_decode, urlsafe_base64_encode
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from .models import Student, Teacher

# Student Registration Serializer
class StudentRegistrationSerializer(serializers.ModelSerializer):
    password2 = serializers.CharField(style={'input_type': 'password'}, write_only=True)

    class Meta:
        model = Student
        fields = ['student_id', 'email', 'first_name', 'last_name', 'batch', 'enrolled_year', 'password', 'password2']
        extra_kwargs = {'password': {'write_only': True}}

    def validate(self, attrs):
        password = attrs.get('password')
        password2 = attrs.get('password2')
        if password != password2:
            raise serializers.ValidationError("Password and Confirm Password doesn't match")
        return attrs

    def create(self, validated_data):
        validated_data.pop('password2')
        return Student.objects.create_user(**validated_data)

# Teacher Registration Serializer
class TeacherRegistrationSerializer(serializers.ModelSerializer):
    password2 = serializers.CharField(style={'input_type': 'password'}, write_only=True)

    class Meta:
        model = Teacher
        fields = ['teacher_id', 'first_name', 'last_name', 'password', 'password2']
        extra_kwargs = {'password': {'write_only': True}}

    def validate(self, attrs):
        password = attrs.get('password')
        password2 = attrs.get('password2')
        if password != password2:
            raise serializers.ValidationError("Password and Confirm Password doesn't match")
        return attrs

    def create(self, validated_data):
        validated_data.pop('password2')
        return Teacher.objects.create_user(**validated_data)

# Student Login Serializer
class StudentLoginSerializer(serializers.ModelSerializer):
    student_id = serializers.CharField(max_length=50)

    class Meta:
        model = Student
        fields = ['student_id', 'password']

# Teacher Login Serializer
class TeacherLoginSerializer(serializers.ModelSerializer):
    teacher_id = serializers.CharField(max_length=50)

    class Meta:
        model = Teacher
        fields = ['teacher_id', 'password']

# Student Profile Serializer
class StudentProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Student
        fields = ['student_id', 'email', 'first_name', 'last_name', 'batch', 'enrolled_year', 'recognized_faces']

# Teacher Profile Serializer
class TeacherProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Teacher
        fields = ['teacher_id', 'first_name', 'last_name']

# Change Password Serializer
class UserChangePasswordSerializer(serializers.Serializer):
    password = serializers.CharField(max_length=128, style={'input_type': 'password'}, write_only=True)
    password2 = serializers.CharField(max_length=128, style={'input_type': 'password'}, write_only=True)

    class Meta:
        fields = ['password', 'password2']

    def validate(self, attrs):
        password = attrs.get('password')
        password2 = attrs.get('password2')
        user = self.context.get('user')
        if password != password2:
            raise serializers.ValidationError("Password and Confirm Password doesn't match")
        user.set_password(password)
        user.save()
        return attrs

# Send Password Reset Email Serializer
class SendPasswordResetEmailSerializer(serializers.Serializer):
    email = serializers.EmailField(max_length=255)

    class Meta:
        fields = ['email']

    def validate(self, attrs):
        email = attrs.get('email')
        user = None
        if Student.objects.filter(email=email).exists():
            user = Student.objects.get(email=email)
        elif Teacher.objects.filter(email=email).exists():
            user = Teacher.objects.get(email=email)

        if user:
            uid = urlsafe_base64_encode(force_bytes(user.pk))
            token = PasswordResetTokenGenerator().make_token(user)
            link = f'http://127.0.0.1:8000/:3000/api/user/reset/{uid}/{token}'
            # Send email logic here (use your utility class if necessary)
            return attrs
        else:
            raise serializers.ValidationError('You are not a Registered User')

# Password Reset Serializer
class UserPasswordResetSerializer(serializers.Serializer):
    password = serializers.CharField(max_length=128, style={'input_type': 'password'}, write_only=True)
    password2 = serializers.CharField(max_length=128, style={'input_type': 'password'}, write_only=True)

    class Meta:
        fields = ['password', 'password2']

    def validate(self, attrs):
        try:
            password = attrs.get('password')
            password2 = attrs.get('password2')
            uid = self.context.get('uid')
            token = self.context.get('token')
            if password != password2:
                raise serializers.ValidationError("Password and Confirm Password doesn't match")
            user_id = smart_str(urlsafe_base64_decode(uid))
            user = None
            if Student.objects.filter(pk=user_id).exists():
                user = Student.objects.get(pk=user_id)
            elif Teacher.objects.filter(pk=user_id).exists():
                user = Teacher.objects.get(pk=user_id)
            if not user or not PasswordResetTokenGenerator().check_token(user, token):
                raise serializers.ValidationError('Token is not valid or expired')
            user.set_password(password)
            user.save()
            return attrs
        except DjangoUnicodeDecodeError:
            raise serializers.ValidationError('Token is not valid or expired')











# from rest_framework import serializers
# from .models import Student, Teacher
# from django.contrib.auth import authenticate


# class StudentSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Student
#         fields = [
#             'student_id', 'password', 'email', 'batch', 
#             'first_name', 'last_name', 'enrolled_year', 
#             'recognized_faces', 'date_joined', 'is_active', 
#             'is_staff'
#         ]
#         extra_kwargs = {
#             'password': {'write_only': True}
#         }

#     def create(self, validated_data):
#         student = Student.objects.create(
#             student_id=validated_data['student_id']
#         )
#         student.set_password(validated_data['password'])
#         student.save()
#         return student

# class TeacherSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Teacher
#         fields = ['teacher_id', 'first_name', 'last_name', 'date_joined', 'is_active', 'is_staff']

#     def create(self, validated_data):
#         teacher = Teacher.objects.create(
#             teacher_id=validated_data['teacher_id']
#         )
#         teacher.set_password(validated_data['password'])
#         teacher.save()
#         return teacher

# class AuthTokenSerializer(serializers.Serializer):
#     student_id = serializers.CharField()
#     password = serializers.CharField(
#         style={'input_type': 'password'},
#         trim_whitespace=False
#     )

#     def validate(self, data):
#         student_id = data.get('student_id')
#         password = data.get('password')

#         if student_id and password:
#             user = authenticate(request=self.context.get('request'),
#                                 student_id=student_id, password=password)

#             if not user:
#                 raise serializers.ValidationError('Invalid credentials')
#         else:
#             raise serializers.ValidationError('Both fields are required')

#         data['user'] = user
#         return data
