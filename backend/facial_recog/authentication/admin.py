from django.contrib import admin
from authentication.models import User
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

class UserModelAdmin(BaseUserAdmin):
    list_display = ('id', 'email', 'first_name', 'last_name', 'teacher_id', 'student_id', 'batch', 'enrolled_year', 'is_staff', 'is_admin')
    list_filter = ('is_admin', 'is_staff')
    fieldsets = (
        ('User Credentials', {'fields': ('email', 'password')}),
        ('Personal info', {'fields': ('first_name', 'last_name', 'teacher_id', 'student_id', 'batch', 'enrolled_year')}),
        ('Permissions', {'fields': ('is_admin', 'is_staff')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'first_name', 'last_name', 'teacher_id', 'student_id', 'batch', 'enrolled_year', 'password1', 'password2'),
        }),
    )
    search_fields = ('email', 'teacher_id', 'student_id')
    ordering = ('email', 'id')
    filter_horizontal = []

admin.site.register(User, UserModelAdmin)
