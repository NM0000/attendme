import os
import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from .models import User 
# StudentImage
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
    StudentImageSerializer
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
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        token = get_tokens_for_user(user)
        return Response({'token': token, 'msg': 'Student Registration Successful'}, status=status.HTTP_201_CREATED)

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

# Teacher Profile View
class TeacherProfileView(APIView):
    renderer_classes = [UserRenderer]
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        serializer = TeacherProfileSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

# User Change Password View
class UserChangePasswordView(APIView):
    renderer_classes = [UserRenderer]
    permission_classes = [IsAuthenticated]

    def post(self, request, format=None):
        serializer = UserChangePasswordSerializer(data=request.data, context={'user': request.user})
        serializer.is_valid(raise_exception=True)
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
class UploadPhotoView(APIView):

    def post(self, request, *args, **kwargs):
        student_id = request.data.get('student_id')
        photo = request.FILES.get('photo')

        if not student_id or not photo:
            return Response({'error': 'Missing student_id or photo'}, status=status.HTTP_400_BAD_REQUEST)

        student = get_object_or_404(User, student_id=student_id)

        serializer = StudentImageSerializer(instance=student, data={'profile_image': photo}, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({'message': 'Photo uploaded successfully'}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
# # Payload Reception View
# @csrf_exempt
# def receive_payload(request):
#     if request.method == 'POST':
#         data = json.loads(request.body)
#         key1 = data.get('key1')
#         key2 = data.get('key2')
#         # Process the data here
#         return JsonResponse({'status': 'success', 'data': data})
#     else:
#         return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=405)
