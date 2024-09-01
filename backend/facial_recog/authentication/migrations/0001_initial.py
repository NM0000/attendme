# Generated by Django 5.0.7 on 2024-09-01 02:44

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('password', models.CharField(max_length=128, verbose_name='password')),
                ('last_login', models.DateTimeField(blank=True, null=True, verbose_name='last login')),
                ('email', models.EmailField(max_length=255, unique=True, verbose_name='Email')),
                ('first_name', models.CharField(max_length=100)),
                ('last_name', models.CharField(max_length=100)),
                ('is_active', models.BooleanField(default=True)),
                ('is_admin', models.BooleanField(default=False)),
                ('is_staff', models.BooleanField(default=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('teacher_id', models.CharField(blank=True, max_length=100, null=True, unique=True)),
                ('student_id', models.CharField(blank=True, max_length=100, null=True, unique=True)),
                ('batch', models.CharField(blank=True, max_length=50, null=True)),
                ('enrolled_year', models.IntegerField(blank=True, null=True)),
            ],
            options={
                'abstract': False,
            },
        ),
    ]
