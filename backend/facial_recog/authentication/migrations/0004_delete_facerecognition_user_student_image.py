# Generated by Django 5.0.7 on 2024-10-27 12:08

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('authentication', '0003_facerecognition_remove_user_profile_image'),
    ]

    operations = [
        migrations.DeleteModel(
            name='FaceRecognition',
        ),
        migrations.AddField(
            model_name='user',
            name='student_image',
            field=models.ImageField(blank=True, null=True, upload_to='images/'),
        ),
    ]
