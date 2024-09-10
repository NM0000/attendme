from django.core.mail import EmailMessage
import os

class Util:
    @staticmethod
    def send_email(data):
        email = EmailMessage(
            subject=data['subject'],
            body=data['body'],
            from_email=os.environ.get('EMAIL_FROM'),  # Fetch the sender's email from environment variables
            to=[data['to_email']]  # Recipient's email
        )
        email.send()


import joblib
import os

# Make sure the correct path is used
model_path = r'D:\IIMS COLLEGE\Bcs 8th sem\attendme\SVC_modell.pkl'

# Load the model using joblib
svc_model = joblib.load(model_path)