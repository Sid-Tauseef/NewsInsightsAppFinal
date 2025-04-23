# app/services/ml_services.py
import joblib
from sklearn.preprocessing import StandardScaler

class MLService:
    model = joblib.load("model.pkl")  # Replace with your model path

    @staticmethod
    def predict(data):
        scaler = StandardScaler()
        scaled_data = scaler.fit_transform([data])
        prediction = MLService.model.predict(scaled_data)
        return prediction.tolist()