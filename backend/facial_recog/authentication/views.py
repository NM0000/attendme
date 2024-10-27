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
    FaceRecognitionSerializer,
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


#Upload Image View
class UploadImagesAPIView(APIView):
    def post(self, request, *args, **kwargs):
        student_id = request.data.get('student_id')
        images = request.FILES.getlist('images')  # Assuming you're sending images as a list

        # Check for required parameters
        if not student_id or not images:
            return Response({'error': 'student_id and images are required'}, status=status.HTTP_400_BAD_REQUEST)

        # Create a folder for the student if it doesn't exist
        student_folder = os.path.join('media/images/', student_id)
        if not os.path.exists(student_folder):
            os.makedirs(student_folder)

        # Save images with unique names
        for count, img in enumerate(images):
            img_name = f'{student_id}_image_{count + 1}.jpg'  # Changed index to start from 1
            img_path = os.path.join(student_folder, img_name)

            # Save the image
            with default_storage.open(img_path, 'wb+') as destination:
                for chunk in img.chunks():
                    destination.write(chunk)

        return Response({'message': 'Images saved successfully'}, status=status.HTTP_200_OK)


  
#facerecog
# face_recognition/views.py
import cv2 as cv
import numpy as np
from rest_framework.views import APIView
from rest_framework.response import Response
from keras_facenet import FaceNet
from sklearn.preprocessing import LabelEncoder
import joblib
import base64
from django.http import QueryDict
# Load FaceNet model and SVM for face recognition
facenet = FaceNet()
faces_embeddings = np.load(r"D:\IIMS COLLEGE\Bcs 8th sem\attendme\ML\faces_embeddings_done_4classes3.npz")
Y = faces_embeddings['arr_1']
encoder = LabelEncoder()
encoder.fit(Y)
model = joblib.load(r"D:\IIMS COLLEGE\Bcs 8th sem\attendme\ML\SVC_model.pkl")
haarcascade = cv.CascadeClassifier(cv.data.haarcascades + "haarcascade_frontalface_default.xml")

class RealTimeFaceRecognitionView(APIView):
    
    def post(self, request):
        # Get the image frame from the request in base64 format
        print(request.data.get('attachment'))
        print("......")
        frame_data = request.data.get('attachment')
        if not frame_data:
            return Response({"error": "No frame data provided"}, status=400)
        
        #convert to image opencv format
        frame = np.asarray(bytearray(frame_data.read()), dtype="uint8")
        frame_ = cv.imdecode(frame, cv.IMREAD_COLOR)
        print(frame_)
        gray_img = cv.cvtColor(frame_, cv.COLOR_BGR2GRAY)
        rgb_img = cv.cvtColor(frame_, cv.COLOR_BGR2RGB)  # Convert frame to RGB format

        # Detect faces in the frame
        faces = haarcascade.detectMultiScale(gray_img, 1.3, 5)
        recognized_name = "Unknown"

        for (x, y, w, h) in faces:
            face_img = rgb_img[y:y+h, x:x+w]
            face_img = cv.resize(face_img, (160, 160))
            face_img = np.expand_dims(face_img, axis=0)

            # Perform face recognition
            ypred = facenet.embeddings(face_img)
            face_name = model.predict(ypred)
            recognized_name = encoder.inverse_transform(face_name)[0]
            print(f"Recognized face: {recognized_name}")

            # Draw rectangle around the face and label it
            cv.rectangle(frame_, (x, y), (x + w, y + h), (255, 0, 0), 2)
            cv.putText(frame_, recognized_name, (x, y - 10), cv.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)

        # Encode the processed frame back to base64 to send it to Flutter
        _, buffer = cv.imencode('.jpg', frame_)
        frame_base64 = base64.b64encode(buffer).decode('utf-8')

        return Response({"recognized_name": recognized_name, "processed_frame": frame_base64})