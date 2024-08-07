from rest_framework import serializers
from .models import Teacher
from .models import Student, StudentImage

class TeacherSerializer(serializers.ModelSerializer):
    class Meta:
        model = Teacher
        fields = ['teacher_id', 'password']
        extra_kwargs = {'password': {'write_only': True}}
    
    def create(self, validated_data):
        teacher = Teacher.objects.create_user(**validated_data)
        return teacher


class StudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Student
        fields = ['student_id', 'first_name', 'last_name', 'batch', 'enrolled_year', 'email', 'password']

class StudentImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = StudentImage
        fields = ['student', 'image', 'angle']
