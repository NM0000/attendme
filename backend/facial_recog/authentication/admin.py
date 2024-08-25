from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import Student, Teacher

class StudentAdmin(BaseUserAdmin):
    list_display = ('student_id', 'email', 'first_name', 'last_name', 'batch', 'enrolled_year','is_active', 'is_staff', 'is_superuser')
    list_filter = ('is_superuser', 'is_staff')
    fieldsets = (
        ('User Credentials', {'fields': ('student_id', 'email', 'password')}),
        ('Personal Info', {'fields': ('first_name', 'last_name', 'batch', 'enrolled_year', 'recognized_faces')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('student_id', 'email', 'first_name', 'last_name', 'batch', 'enrolled_year', 'password1', 'password2'),
        }),
    )
    search_fields = ('student_id', 'email')
    ordering = ('student_id', 'email')
    filter_horizontal = ()

class TeacherAdmin(BaseUserAdmin):
    list_display = ('teacher_id', 'first_name', 'last_name','is_active', 'is_staff', 'is_superuser')
    list_filter = ('is_superuser', 'is_staff')
    fieldsets = (
        ('User Credentials', {'fields': ('teacher_id', 'password')}),
        ('Personal Info', {'fields': ('first_name', 'last_name')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('teacher_id', 'first_name', 'last_name', 'password1', 'password2'),
        }),
    )
    search_fields = ('teacher_id',)
    ordering = ('teacher_id',)
    filter_horizontal = ()

# Register the models with the custom admin classes
admin.site.register(Student, StudentAdmin)
admin.site.register(Teacher, TeacherAdmin)