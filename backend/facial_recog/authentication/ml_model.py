# authentication/ml_model.py
import joblib
from PIL import Image
import numpy as np




from .utils import preprocess_image  # Import a function to preprocess images

model = load_model()  # Load the model once

def predict_face(photo_path):
    image = preprocess_image(photo_path)
    prediction = model.predict(image)
    return prediction

def update_model(student_id, photo_path):
    image = preprocess_image(photo_path)
    encoding = extract_face_encoding(image)  # Replace with your actual encoding function
    # Add your logic to update the model with new encoding
    # e.g., model.update(student_id, encoding)


def preprocess_image(photo_path):
    # Open and preprocess the image
    image = Image.open(photo_path)
    # Convert image to numpy array or other required format
    image_array = np.array(image)
    return image_array

def extract_face_encoding(image):
    # Implement your face encoding extraction
    # This depends on your model and approach
    encoding = some_face_encoding_function(image)
    return encoding

def update_model(student_id, photo_path):
    image = preprocess_image(photo_path)
    encoding = extract_face_encoding(image)
    # Implement model update logic here
    # e.g., model.update(student_id, encoding)
