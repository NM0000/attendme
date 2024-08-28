# authentication/views.py
import os
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage

@csrf_exempt
def upload_photo(request):
    if request.method == 'POST':
        student_id = request.POST.get('student_id')
        photo = request.FILES.get('photo')
        if not student_id or not photo:
            return JsonResponse({'error': 'Missing student_id or photo'}, status=400)

        # Create a directory for the student if it doesn't exist
        student_dir = os.path.join('media', 'photos', student_id)
        if not os.path.exists(student_dir):
            os.makedirs(student_dir)

        # Save the photo
        file_path = os.path.join(student_dir, photo.name)
        with default_storage.open(file_path, 'wb+') as destination:
            for chunk in photo.chunks():
                destination.write(chunk)

        # Call your function to update the model
        update_model(student_id, file_path)

        return JsonResponse({'message': 'Photo uploaded successfully'})
    return JsonResponse({'error': 'Invalid method'}, status=405)

def update_model(student_id, file_path):
    # Placeholder for updating the model with new images
    # Implement your model update logic here
    pass


from rest_framework.response import Response
from authentication.renderers import UserRenderer
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import (
    StudentRegistrationSerializer,
    StudentLoginSerializer,
    TeacherRegistrationSerializer,
    TeacherLoginSerializer,
    StudentProfileSerializer,
    TeacherProfileSerializer,
    SendPasswordResetEmailSerializer,
    UserPasswordResetSerializer,
)
from django.contrib.auth import authenticate

# Generate JWT Token
def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

# Student Registration View
class StudentRegistrationView(APIView):
    renderer_classes = [UserRenderer]
    def post(self, request, format=None):
        serializer = StudentRegistrationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        student = serializer.save()
        token = get_tokens_for_user(student)
        return Response({'token': token, 'msg': 'Registration Successful'}, status=status.HTTP_201_CREATED)

# Student Login View
class StudentLoginView(APIView):
    renderer_classes = [UserRenderer]
    def post(self, request, format=None):
        serializer = StudentLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        student_id = serializer.data.get('student_id')
        password = serializer.data.get('password')
        student = authenticate(student_id=student_id, password=password)
        
        if student is not None:
            token = get_tokens_for_user(student)
            return Response({'token': token, 'msg': 'Login Success'}, status=status.HTTP_200_OK)
        else:
            return Response({'errors': {'non_field_errors': ['Student ID or Password is not valid']}}, status=status.HTTP_404_NOT_FOUND)

# Teacher Registration View
class TeacherRegistrationView(APIView):
    renderer_classes = [UserRenderer]
    def post(self, request, format=None):
        serializer = TeacherRegistrationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        teacher = serializer.save()
        token = get_tokens_for_user(teacher)
        return Response({'token': token, 'msg': 'Registration Successful'}, status=status.HTTP_201_CREATED)

# Teacher Login View
class TeacherLoginView(APIView):
    renderer_classes = [UserRenderer]

    def post(self, request, format=None):
        serializer = TeacherLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        teacher_id = serializer.data.get('teacher_id')
        password = serializer.data.get('password')

        teacher = authenticate(username=teacher_id, password=password)

        if teacher is not None:
            token = get_tokens_for_user(teacher)
            return Response({'token': token, 'msg': 'Login Success'}, status=status.HTTP_200_OK)
        else:
            return Response({'errors': {'non_field_errors': ['Teacher ID or Password is not valid']}}, status=status.HTTP_404_NOT_FOUND)

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
