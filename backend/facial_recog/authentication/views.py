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
from .models import User, Attendance 
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
    AttendanceSerializer,
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
    permission_classes = [IsAuthenticated]  # Only authenticated users can upload images

    def post(self, request):
        user = request.user  # Get the currently authenticated user

        # Expecting exactly 12 images
        images = request.FILES.getlist('images')
        if len(images) != 12:
            return Response({'error': 'Please upload exactly 12 images.'}, status=status.HTTP_400_BAD_REQUEST)

        # Define the paths where the images will be saved
        train_dir = os.path.join(settings.MEDIA_ROOT, 'Dataset', 'train')
        test_dir = os.path.join(settings.MEDIA_ROOT, 'Dataset', 'test')

        # Ensure directories exist
        os.makedirs(train_dir, exist_ok=True)
        os.makedirs(test_dir, exist_ok=True)

        # Save the first 9 images to the train directory and the last 3 to the test directory
        for i, image in enumerate(images):
            if i < 9:
                # Save in the training directory
                save_path = os.path.join(train_dir, f'{user.id}_{i+1}.jpg')
            else:
                # Save in the test directory
                save_path = os.path.join(test_dir, f'{user.id}_{i+1}.jpg')

            # Use Django's default storage system to save the images
            with default_storage.open(save_path, 'wb+') as destination:
                for chunk in image.chunks():
                    destination.write(chunk)

        return Response({'message': 'Images uploaded successfully.'}, status=status.HTTP_201_CREATED)


  
#face_recognition
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

#Attandance_report_views.py
class AttendanceListCreateView(APIView):
    
    def get(self, request):
        # Fetch all attendance records
        attendance_records = Attendance.objects.all()
        serializer = AttendanceSerializer(attendance_records, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        # Get the recognized students from request data
        recognized_students = request.data.get('recognized_students', [])
        
        if not recognized_students:
            return Response({"error": "No recognized students provided."}, status=status.HTTP_400_BAD_REQUEST)

        # Update attendance for recognized students
        for student in User.objects.filter(student_id__in=recognized_students):
            attendance, created = Attendance.objects.get_or_create(student=student)
            attendance.total_classes += 1
            attendance.present_count += 1
            attendance.save()

        # Update attendance for absent students (those not recognized)
        all_students = User.objects.filter(student_id__isnull=False)
        for student in all_students:
            if student.student_id not in recognized_students:
                attendance, created = Attendance.objects.get_or_create(student=student)
                attendance.total_classes += 1
                attendance.absent_count += 1
                attendance.save()

        return Response({"message": "Attendance updated successfully"}, status=status.HTTP_200_OK)

class AttendanceRetrieveUpdateView(APIView):

    def get(self, request, student_id):
        try:
            attendance = Attendance.objects.get(student__student_id=student_id)
            serializer = AttendanceSerializer(attendance)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Attendance.DoesNotExist:
            return Response({"error": "Attendance record not found"}, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, student_id):
        try:
            attendance = Attendance.objects.get(student__student_id=student_id)
        except Attendance.DoesNotExist:
            return Response({"error": "Attendance record not found"}, status=status.HTTP_404_NOT_FOUND)

        recognized_students = request.data.get('recognized_students', [])
        
        if student_id in recognized_students:
            attendance.present_count += 1  # Mark as present
        else:
            attendance.absent_count += 1  # Mark as absent

        attendance.total_classes += 1
        attendance.save()

        serializer = AttendanceSerializer(attendance)
        return Response(serializer.data, status=status.HTTP_200_OK)

class AttendanceDetailView(APIView):

    def get(self, request, student_id):
        try:
            attendance = Attendance.objects.get(student__student_id=student_id)
            serializer = AttendanceSerializer(attendance)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Attendance.DoesNotExist:
            return Response({"error": "Attendance record not found"}, status=status.HTTP_404_NOT_FOUND)

