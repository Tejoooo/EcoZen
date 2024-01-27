from django.shortcuts import render
from django.http import HttpResponse
from rest_framework import generics
from rest_framework.response import Response
from rest_framework import status
from .models import UserModel, UserProblem,UploadedImage,ZenCoins
from .serializers import UserModelSerializer,UserProblemSerializer
from rest_framework.views import APIView
from rest_framework import status
from roboflow import Roboflow
from dotenv import load_dotenv
import os
from django.shortcuts import get_object_or_404
import urllib.request
import json
from twilio.rest import Client
from math import radians, sin, cos, sqrt, atan2

#from django.contrib.gis.geos import Point
#from django.contrib.gis.db.models.functions import Distance

load_dotenv()
TWILIO_ACCOUNT_SID = os.getenv('TWILIO_ACCOUNT_SID')
TWILIO_AUTH_TOKEN = os.getenv('TWILIO_AUTH_TOKEN')
TWILIO_PHONE_NUMBER = os.getenv('TWILIO_PHONE_NUMBER')


def home(request):
    return HttpResponse("hello world")

#For creating the user id
class UserModelView(generics.CreateAPIView):
    serializer_class = UserModelSerializer

    def create(self, request, *args, **kwargs):
        try:
            user_id = int(request.data.get('user_id'))
            email = request.data.get('email')
            phone_number = request.data.get('phone_number')
            name = request.data.get('name')
            address = request.data.get('address')
            city = request.data.get('city', None)
            state = request.data.get('state', None)
            pincode = request.data.get('pincode', None)

            if user_id:
                user_instance, created = UserModel.objects.get_or_create(
                    user=user_id,email=email,phone_number=phone_number,name=name,address=address,city=city,state=state,pincode=pincode
                )

                if created:
                    return Response({"detail": "User ID created successfully."}, status=status.HTTP_201_CREATED)
                else:
                    return Response({"detail": "User ID already exists."}, status=status.HTTP_200_OK)

        except ValueError:
            return Response({"detail": "Invalid user ID provided."}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({"detail": f"An error occurred: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
# For Image uploaded by users
class ImageUploadView(APIView):
    global model
    def post(self, request, *args, **kwargs):
        serializer = UserProblemSerializer(data=request.data)
        print(request.data)
        if serializer.is_valid():
            try:
                user = serializer.validated_data.get('user')
                description = serializer.validated_data['description']
                latitude = serializer.validated_data['latitude']
                longitude = serializer.validated_data['longitude']
                latitude=float(latitude)
                longitude=float(latitude)
                image = request.FILES.get('image', None)
                print(latitude,longitude)

                # Check if image is provided
                if not image:
                    return Response({'message': 'No image file provided.'}, status=status.HTTP_400_BAD_REQUEST)

                # Save the image
                UploadedImage.objects.create(image=image)

                rf = Roboflow(api_key=os.getenv('api_key'))
                project = rf.workspace().project("garbage_detection-wvzwv")
                model = project.version(9).model
                result = model.predict(f"media/user_problem_images/{image}", confidence=40, overlap=30).json()
                print(result)
                # Check if the image is classified as garbage
                if len(result.get('predictions')) > 0:
                    user_problem = UserProblem.objects.create(
                        user=user, description=description, image=result['predictions'][0]['image_path'],latitude=latitude,longitude=longitude,status=UserProblem.ProblemStatus.SUBMITTED
                    )
                    return Response({'message': 'Image is classified as garbage. Data stored.'}, status=status.HTTP_201_CREATED)
                else:
                    # Delete the image if it's not classified as garbage
                    try:
                        image_instance = UploadedImage.objects.get(image=f"media/user_problem_images/{image}")
                        image_instance.delete()
                        print(f"Image {image} deleted successfully.")
                    except UploadedImage.DoesNotExist:
                        print(f"Image {image} not found.")
                    finally:
                        return Response({'message': 'Image is not classified as garbage. Data not stored.'}, status=status.HTTP_400_BAD_REQUEST)
            
            except Exception as e:
                print(str(e))
                return Response({'message': f"An error occurred: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

class IncreaseCoinsAPIView(APIView):
    def post(self, request, user_id):
        user = get_object_or_404(UserModel, user=user_id)
        zen_coins, created = ZenCoins.objects.get_or_create(user=user)
        zen_coins.zen_coins += 1
        zen_coins.save()
        return Response({"detail": "Zen Coins increased successfully."}, status=status.HTTP_200_OK)
    
class UserExistsAPIView(APIView):
    def get(self, request, user_id):
        try:
            # Try to get the user based on the user_id
            user = UserModel.objects.get(user=user_id)
            return Response({"exists": True, "detail": "User exists."}, status=status.HTTP_200_OK)

        except UserModel.DoesNotExist:
            # User does not exist
            return Response({"exists": False, "detail": "User does not exist."}, status=status.HTTP_404_NOT_FOUND)
        

        
class UserProblemListAPIView(APIView):
    def get(self, request):
        user_problems = UserProblem.objects.filter(status=UserProblem.ProblemStatus.SUBMITTED)
        serializer = UserProblemSerializer(user_problems, many=True)
        print(serializer.data)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
def send_sms(user,message):
    phone_number=user.phone_number
    if phone_number[0]!='+':
        phone_number='+91'+phone_number
    account_sid = TWILIO_ACCOUNT_SID
    auth_token = TWILIO_AUTH_TOKEN
    twilio_phone_number = TWILIO_PHONE_NUMBER
    client = Client(account_sid, auth_token)
    message = client.messages.create(
        body=f"Your OTP for registration: {message}",
        from_=twilio_phone_number,
        to=phone_number
    )

class OptimalRoutesAPIView(APIView):
    def post(self, request):
        # Get input latitude and longitude from the request data
        input_latitude = float(request.data.get('latitude'))
        input_longitude = float(request.data.get('longitude'))

        # Create a LatLng object from the input latitude and longitude
        input_point = LatLng(latitude=input_latitude, longitude=input_longitude)

        # Define the radius in kilometers
        radius_km = 10

        # Filter UserProblem instances within the specified radius
        user_problems = UserProblem.objects.all()  # Replace with your actual model queryset

        # Use the provided function to filter points within the radius
        points_within_radius = self.get_points_within_radius(user_problems, input_point, radius_km)
        print(points_within_radius)

        # Prepare data for the optimal route (you can customize this based on your requirements)
        data = {
            "visits": {
                f"order_{i+1}": {
                    "location": {
                        "name": f"Location {i+1}",
                        "lat": "22.19",
                        "lng": "22.19"
                    }
                } for i, problem in enumerate(points_within_radius)
            },
            "fleet": {
                f"vehicle_{i+1}": {
                    "start_location": {
                        "id": "depot",
                        "name": "Depot",
                        "lat": input_latitude,
                        "lng": input_longitude
                    }
                } for i in range(len(points_within_radius))
            }
        }

        # Assuming you have a Routific API URL and token
        routific_url = "https://api.routific.com/v1/vrp"
        routific_token = 'your_routific_token_here'

        # Convert data payload to bytes
        data_bytes = json.dumps(data).encode('utf-8')

        # Create a request object
        req = urllib.request.Request(routific_url, data_bytes, headers={'Content-Type': 'application/json', 'Authorization': 'bearer ' + routific_token})

        try:
            # Get route from Routific
            with urllib.request.urlopen(req) as response:
                res = response.read().decode('utf-8')

            return Response({"routes": json.loads(res)}, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    def get_points_within_radius(self, all_points, center, radius):
        points_within_radius = []

        for point in all_points:
            distance = self.calculate_haversine_distance(center, point)
            if distance <= radius:
                points_within_radius.append(point)

        return points_within_radius

    def calculate_haversine_distance(self, point1, point2):
        # Radius of the Earth in kilometers
        earth_radius = 6371.0

        def degrees_to_radians(degrees):
            return degrees * (3.141592653589793 / 180.0)

        def haversine(theta):
            return sin(theta / 2) ** 2

        def get_distance(p1, p2):
            lat1 = degrees_to_radians(p1.latitude)
            lon1 = degrees_to_radians(p1.longitude)
            lat2 = degrees_to_radians(p2.latitude)
            lon2 = degrees_to_radians(p2.longitude)

            d_lat = lat2 - lat1
            d_lon = lon2 - lon1

            a = haversine(d_lat) + cos(lat1) * cos(lat2) * haversine(d_lon)
            c = 2 * atan2(sqrt(a), sqrt(1 - a))

            return earth_radius * c  # Distance in kilometers

        return get_distance(point1, point2)

class LatLng:
    def __init__(self, latitude, longitude):
        self.latitude = latitude
        self.longitude = longitude

    def __repr__(self):
        return f"LatLng({self.latitude}, {self.longitude})"


class LatLng:
    def _init_(self, latitude, longitude):
        self.latitude = latitude
        self.longitude = longitude

def calculate_haversine_distance(point1, point2):
    # Radius of the Earth in kilometers
    earth_radius = 6371.0

    def degrees_to_radians(degrees):
        return degrees * (3.141592653589793 / 180.0)

    def haversine(theta):
        return sin(theta / 2) ** 2

    def get_distance(p1, p2):
        lat1 = degrees_to_radians(p1.latitude)
        lon1 = degrees_to_radians(p1.longitude)
        lat2 = degrees_to_radians(p2.latitude)
        lon2 = degrees_to_radians(p2.longitude)

        d_lat = lat2 - lat1
        d_lon = lon2 - lon1

        a = haversine(d_lat) + cos(lat1) * cos(lat2) * haversine(d_lon)
        c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earth_radius * c  # Distance in kilometers

    return get_distance(point1, point2)

def get_points_within_radius(all_points, center, radius):
    points_within_radius = []

    for point in all_points:
        distance = calculate_haversine_distance(center, point)
        if distance <= radius:
            points_within_radius.append(point)

    return points_within_radius


    





