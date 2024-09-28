import os
import json
from django.http import JsonResponse
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from .models import User 
from .serializers import (
    TeacherRegistrationSerializer,
    StudentRegistrationSerializer,
    TeacherLoginSerializer,
    StudentLoginSerializer,
    StudentProfileSerializer,
    TeacherProfileSerializer,
    SendPasswordResetEmailSerializer,
    UserPasswordResetSerializer,
    UserChangePasswordSerializer,
)
from .renderers import UserRenderer
from django.contrib.auth import authenticate

# Utility function to generate tokens for a user
def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

# Teacher Registration View
class TeacherRegistrationView(APIView):
    def post(self, request, format=None):
        serializer = TeacherRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token = get_tokens_for_user(user)
            return Response(
                {
                    'token': token, 
                    'msg': 'Teacher Registration Successful'
                }, 
                status=status.HTTP_201_CREATED
            )
        else:
            return Response(
                {
                    'errors': serializer.errors, 
                    'msg': 'Teacher Registration Failed'
                }, 
                status=status.HTTP_400_BAD_REQUEST
            )

# Student Registration View
class StudentRegistrationView(APIView):
    def post(self, request, format=None):
        serializer = StudentRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            student = serializer.save()  # Create student and handle images
            token = get_tokens_for_user(student)  # Generate tokens
            
            return Response({
                'token': token,
                'msg': 'Student Registration Successful'
            }, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Teacher Login View
class TeacherLoginView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = TeacherLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data
        token = get_tokens_for_user(user)
        return Response({'token': token, 'message': 'Teacher login successful'}, status=status.HTTP_200_OK)

# Student Login View
class StudentLoginView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = StudentLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data
        token = get_tokens_for_user(user)
        return Response({'token': token, 'message': 'Student login successful'}, status=status.HTTP_200_OK)

# Student Profile View
class StudentProfileView(APIView):
    renderer_classes = [UserRenderer]
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        serializer = StudentProfileSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
class StudentListAPI(APIView):
    def get(self, request):
        students = User.objects.filter(student_id__isnull=False).values('student_id','first_name', 'last_name', 'email','batch','enrolled_year')
        return Response(students, status=status.HTTP_200_OK)

# Teacher Profile View
class TeacherProfileView(APIView):
    renderer_classes = [UserRenderer]
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        serializer = TeacherProfileSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

class TeacherListAPI(APIView):
    def get(self, request):
        teachers = User.objects.filter(teacher_id__isnull=False).values('first_name', 'last_name', 'email')
        return Response(teachers, status=status.HTTP_200_OK)

# User Change Password View
class UserChangePasswordView(APIView):
    renderer_classes = [UserRenderer]
    permission_classes = [IsAuthenticated]

    def post(self, request, format=None):
        serializer = UserChangePasswordSerializer(data=request.data, context={'user': request.user})
        if serializer.is_valid(raise_exception=True):
          return Response({'msg': 'Password Changed Successfully'}, status=status.HTTP_200_OK)

# Send Password Reset Email View
class SendPasswordResetEmailView(APIView):
    renderer_classes = [UserRenderer]

    def post(self, request, format=None):
        serializer = SendPasswordResetEmailSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response({'msg': 'Password reset link sent. Please check your email.'}, status=status.HTTP_200_OK)

# User Password Reset View
class UserPasswordResetView(APIView):
    renderer_classes = [UserRenderer]

    def post(self, request, uid, token, format=None):
        serializer = UserPasswordResetSerializer(data=request.data, context={'uid': uid, 'token': token})
        serializer.is_valid(raise_exception=True)
        return Response({'msg': 'Password reset successfully.'}, status=status.HTTP_200_OK)

class UploadImageAPIView(APIView):
    def post(self, request, *args, **kwargs):
        if 'image' not in request.FILES:
            return Response({'error': 'No image provided'}, status=status.HTTP_400_BAD_REQUEST)

        image_file = request.FILES['image']  # Get the uploaded image
        file_name = default_storage.save(image_file.name, ContentFile(image_file.read()))
        file_url = default_storage.url(file_name)

        return Response({'status': 'success', 'file_url': file_url}, status=status.HTTP_201_CREATED)