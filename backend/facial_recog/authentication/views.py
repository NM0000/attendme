from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import (
    StudentRegistrationSerializer,
    TeacherRegistrationSerializer,
    StudentLoginSerializer,
    TeacherLoginSerializer,
    StudentProfileSerializer,
    TeacherProfileSerializer,
    UserChangePasswordSerializer,
    SendPasswordResetEmailSerializer,
    UserPasswordResetSerializer
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
    def post(self, request, format=None):
        serializer = StudentRegistrationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        student = serializer.save()
        token = get_tokens_for_user(student)
        return Response({'token': token, 'msg': 'Registration Successful'}, status=status.HTTP_201_CREATED)

# Teacher Registration View
class TeacherRegistrationView(APIView):
    def post(self, request, format=None):
        serializer = TeacherRegistrationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        teacher = serializer.save()
        token = get_tokens_for_user(teacher)
        return Response({'token': token, 'msg': 'Registration Successful'}, status=status.HTTP_201_CREATED)

# Student Login View
class StudentLoginView(APIView):
    def post(self, request, format=None):
        serializer = StudentLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        student_id = serializer.data.get('student_id')
        password = serializer.data.get('password')
        
        # Pass 'username' argument to authenticate
        student = authenticate(username=student_id, password=password)
        
        if student is not None:
            token = get_tokens_for_user(student)
            return Response({'token': token, 'msg': 'Login Success'}, status=status.HTTP_200_OK)
        else:
            return Response({'errors': {'non_field_errors': ['Student ID or Password is not valid']}}, status=status.HTTP_404_NOT_FOUND)
            
# Teacher Login View
class TeacherLoginView(APIView):
    def post(self, request, format=None):
        serializer = TeacherLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        teacher_id = serializer.data.get('teacher_id')
        password = serializer.data.get('password')
        teacher = authenticate(teacher_id=teacher_id, password=password)
        if teacher is not None:
            token = get_tokens_for_user(teacher)
            return Response({'token': token, 'msg': 'Login Success'}, status=status.HTTP_200_OK)
        else:
            return Response({'errors': {'non_field_errors': ['Teacher ID or Password is not valid']}}, status=status.HTTP_404_NOT_FOUND)

# Student Profile View
class StudentProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        serializer = StudentProfileSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

# Teacher Profile View
class TeacherProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        serializer = TeacherProfileSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

# User Change Password View
class UserChangePasswordView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, format=None):
        serializer = UserChangePasswordSerializer(data=request.data, context={'user': request.user})
        serializer.is_valid(raise_exception=True)
        return Response({'msg': 'Password Changed Successfully'}, status=status.HTTP_200_OK)

# Send Password Reset Email View
class SendPasswordResetEmailView(APIView):
    def post(self, request, format=None):
        serializer = SendPasswordResetEmailSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response({'msg': 'Password reset link sent. Please check your email.'}, status=status.HTTP_200_OK)

# User Password Reset View
class UserPasswordResetView(APIView):
    def post(self, request, uid, token, format=None):
        serializer = UserPasswordResetSerializer(data=request.data, context={'uid': uid, 'token': token})
        serializer.is_valid(raise_exception=True)
        return Response({'msg': 'Password reset successfully.'}, status=status.HTTP_200_OK)



    # from rest_framework import generics
    # from rest_framework.response import Response
    # from rest_framework_simplejwt.tokens import RefreshToken
    # from .models import Student, Teacher
    # from .serializers import StudentSerializer, TeacherSerializer, AuthTokenSerializer

    # class StudentRegisterView(generics.CreateAPIView):
    #     queryset = Student.objects.all()
    #     serializer_class = StudentSerializer

    # class TeacherRegisterView(generics.CreateAPIView):
    #     queryset = Teacher.objects.all()
    #     serializer_class = TeacherSerializer

    # class LoginView(generics.GenericAPIView):
    #     serializer_class = AuthTokenSerializer

    #     def post(self, request, *args, **kwargs):
    #         serializer = self.get_serializer(data=request.data)
    #         serializer.is_valid(raise_exception=True)
    #         user = serializer.validated_data['user']
    #         refresh = RefreshToken.for_user(user)
    #         return Response({
    #             'refresh': str(refresh),
    #             'access': str(refresh.access_token),
    #         })
