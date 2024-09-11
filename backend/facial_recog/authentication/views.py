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

from .utils import svc_model
from PIL import Image
import numpy as np
import io
from PIL import Image
import numpy as np
from sklearn.decomposition import PCA
import joblib

class ImageRecognition(APIView):
    def post(self, request, *args, **kwargs):
        image_file = request.FILES.get('image', None)

        if image_file is None:
            return JsonResponse({'error': 'No image file uploaded'}, status=400)

        # Load the image and preprocess
        img = Image.open(image_file)
        img = img.resize((64, 64))  # Example resizing
        img_array = np.array(img).flatten()

        # Load pre-trained PCA model
        with open('pca_model.pkl', 'rb') as pca_file:
            pca = joblib.load(pca_file)

        # Apply PCA transformation (do not use fit_transform)
        reduced_img_array = pca.transform([img_array])

        # Use the reduced features for model prediction
        prediction = svc_model.predict(reduced_img_array)

        return JsonResponse({'prediction': prediction[0]})



# #imageprediction
# class ImagePredictView(APIView):
#     def post(self, request):
#         # Handle image upload
#         image_file = request.FILES.get('image')
        
#         if not image_file:
#             return JsonResponse({'error': 'No image file provided'}, status=400)

#         try:
#             # Open the image using PIL
#             image = Image.open(image_file)
            
#             # Preprocess the image (resize, convert to grayscale, flatten, etc.)
#             image = image.resize((64, 64))  # Adjust based on your model's requirements
#             image_array = np.array(image).flatten()  # Convert image to a flat array
#             image_array = image_array.reshape(1, -1)  # Reshape for model input
            
#             # Make the prediction using the loaded model
#             prediction = svc_model.predict(image_array)
#             result = prediction[0]
#         except Exception as e:
#             return JsonResponse({'error': str(e)}, status=500)

#         return JsonResponse({'prediction': result}, status=200)
        
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
