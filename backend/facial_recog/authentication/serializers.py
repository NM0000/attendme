from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import User
from django.utils.http import urlsafe_base64_decode, urlsafe_base64_encode
from django.utils.encoding import force_bytes, smart_str, DjangoUnicodeDecodeError
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from authentication.utils import Util


# Teacher Registration Serializer
class TeacherRegistrationSerializer(serializers.ModelSerializer):
    password2 = serializers.CharField(style={'input_type': 'password'}, write_only=True)

    class Meta:
        model = User
        fields = ['email', 'first_name', 'last_name', 'teacher_id', 'password', 'password2']
        extra_kwargs = {
            'password': {'write_only': True},
            'teacher_id': {'required': True},
        }

    def validate(self, attrs):
        password = attrs.get('password')
        password2 = attrs.get('password2')
        if password != password2:
            raise serializers.ValidationError("Password and Confirm Password don't match")
        return attrs

    def create(self, validated_data):
        validated_data.pop('password2', None)
        return User.objects.create_user(**validated_data, is_staff=True)


# Student Registration Serializer
class StudentRegistrationSerializer(serializers.ModelSerializer):

    password2 = serializers.CharField(style={'input_type': 'password'}, write_only=True)
    student_image = serializers.ImageField(required=True)  # Image upload field
    class Meta:
        model = User
        fields = [
            'student_id', 'first_name', 'last_name', 'batch', 
            'enrolled_year', 'email', 'password', 'password2', 'student_image'
        ]
        extra_kwargs = {
            'password': {'write_only': True},
            'student_id': {'required': True},
        }

    def validate(self, attrs):
        password = attrs.get('password')
        password2 = attrs.get('password2')
        if password != password2:
            raise serializers.ValidationError("Password and Confirm Password don't match")
        return attrs
        


    def create(self, validated_data):
        validated_data.pop('password2', None)
        student_image = validated_data.pop('student_image')
        user = User.objects.create_user(**validated_data, is_staff=False)
        user.student_image = student_image  # Save image to the user
        user.save()
        return user
# Teacher Login Serializer
class TeacherLoginSerializer(serializers.Serializer):
    email_or_teacher_id = serializers.CharField()
    password = serializers.CharField()

    def validate(self, data):
        email_or_teacher_id = data.get('email_or_teacher_id')
        password = data.get('password')

        user = None
        # Authenticate by email
        if '@' in email_or_teacher_id:
            user = authenticate(email=email_or_teacher_id, password=password)
        # Authenticate by teacher_id
        else:
            try:
                user = User.objects.get(teacher_id=email_or_teacher_id)
                if not user.check_password(password):
                    raise serializers.ValidationError('Invalid credentials')
            except User.DoesNotExist:
                raise serializers.ValidationError('Invalid credentials')

        # Ensure the user is a teacher (staff)
        if user is None or not user.is_staff:
            raise serializers.ValidationError('Invalid credentials')

        return user

# Student Login Serializer
class StudentLoginSerializer(serializers.Serializer):
    email_or_student_id = serializers.CharField()
    password = serializers.CharField()

    def validate(self, data):
        email_or_student_id = data.get('email_or_student_id')
        password = data.get('password')

        user = None
        # Authenticate by email
        if '@' in email_or_student_id:
            user = authenticate(email=email_or_student_id, password=password)
        # Authenticate by student_id
        else:
            try:
                user = User.objects.get(student_id=email_or_student_id)
                if not user.check_password(password):
                    raise serializers.ValidationError('Invalid credentials')
            except User.DoesNotExist:
                raise serializers.ValidationError('Invalid credentials')

        # Ensure the user is not a staff member (only students can log in)
        if user is None or user.is_staff:
            raise serializers.ValidationError('Invalid credentials')

        return user


# Student Profile Serializer
class StudentProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['student_id', 'email', 'first_name', 'last_name', 'batch', 'enrolled_year']


# Teacher Profile Serializer
class TeacherProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['teacher_id', 'email', 'first_name', 'last_name']


# Change Password Serializer
class UserChangePasswordSerializer(serializers.Serializer):
    current_password = serializers.CharField(max_length=128, style={'input_type': 'password'}, write_only=True)
    password = serializers.CharField(max_length=128, style={'input_type': 'password'}, write_only=True)
    password2 = serializers.CharField(max_length=128, style={'input_type': 'password'}, write_only=True)

    def validate(self, attrs):
        current_password = attrs.get('current_password')
        password = attrs.get('password')
        password2 = attrs.get('password2')
        user = self.context.get('user')

        # Validate current password
        if not user.check_password(current_password):
            raise serializers.ValidationError("Current password is incorrect")

        # Validate new password and confirm password
        if password != password2:
            raise serializers.ValidationError("Password and Confirm Password don't match")

        return attrs

    def save(self, **kwargs):
        user = self.context.get('user')
        # Set new password
        user.set_password(password)
        user.save()  # Ensure the password change is saved in the database
        return attrs



# Send Password Reset Email Serializer
class SendPasswordResetEmailSerializer(serializers.Serializer):
    email = serializers.EmailField(max_length=255)

    def validate(self, attrs):
        email = attrs.get('email')
        user = None
        if User.objects.filter(email=email, is_staff=False).exists():
            user = User.objects.get(email=email, is_staff=False)
        elif User.objects.filter(email=email, is_staff=True).exists():
            user = User.objects.get(email=email, is_staff=True)

        if user:
            uid = urlsafe_base64_encode(force_bytes(user.pk))
            token = PasswordResetTokenGenerator().make_token(user)
            link = f'http://localhost:3000/api/user/reset/{uid}/{token}'
            # Logic to send email (use Util class for this)
            Util.send_email(link, user.email)  # Assuming Util has a send_email method
            return attrs
        else:
            raise serializers.ValidationError('You are not a Registered User')


# Password Reset Serializer
class UserPasswordResetSerializer(serializers.Serializer):
    password = serializers.CharField(max_length=128, style={'input_type': 'password'}, write_only=True)
    password2 = serializers.CharField(max_length=128, style={'input_type': 'password'}, write_only=True)

    def validate(self, attrs):
        try:
            password = attrs.get('password')
            password2 = attrs.get('password2')
            uid = self.context.get('uid')
            token = self.context.get('token')
            if password != password2:
                raise serializers.ValidationError("Password and Confirm Password don't match")
            user_id = smart_str(urlsafe_base64_decode(uid))
            user = User.objects.get(pk=user_id)
            if not PasswordResetTokenGenerator().check_token(user, token):
                raise serializers.ValidationError('Token is not valid or expired')
            user.set_password(password)
            user.save()
            return attrs
        except DjangoUnicodeDecodeError:
            raise serializers.ValidationError('Token is not valid or expired')

#facerecog
from rest_framework import serializers

class FaceRecognitionSerializer(serializers.Serializer):
    image = serializers.ImageField()
