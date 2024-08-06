# from rest_framework import viewsets
# from .models import Student
# from .serializers import StudentSerializer

# class StudentViewSet(viewsets.ModelViewSet):
#     queryset = Student.objects.all()
#     serializer_class = StudentSerializer


from rest_framework import viewsets, status
from rest_framework.permissions import AllowAny
from .models import Student, StudentImage
from .models import Teacher
from .serializers import TeacherSerializer
from .serializers import StudentSerializer, StudentImageSerializer

class TeacherViewSet(viewsets.ModelViewSet):
    queryset = Teacher.objects.all()
    serializer_class = TeacherSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        teacher_id = request.data.get('teacher_id')
        password = request.data.get('password')
        teacher = Teacher(teacher_id=teacher_id, password=password)
        teacher.save()
        return Response({'access': 'fake-access-token', 'refresh': 'fake-refresh-token'}, status=201)



class StudentViewSet(viewsets.ModelViewSet):
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        student = Student.objects.create_user(
            student_id=serializer.validated_data['student_id'],
            first_name=serializer.validated_data['first_name'],
            last_name=serializer.validated_data['last_name'],
            batch=serializer.validated_data['batch'],
            enrolled_year=serializer.validated_data['enrolled_year'],
            email=serializer.validated_data['email'],
            password=serializer.validated_data['password']
        )
        return Response({'message': 'Student registered successfully.'}, status=status.HTTP_201_CREATED)

class StudentImageViewSet(viewsets.ModelViewSet):
    queryset = StudentImage.objects.all()
    serializer_class = StudentImageSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'message': 'Image uploaded successfully.'}, status=status.HTTP_201_CREATED)
