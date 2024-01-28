from django.shortcuts import render
from django.http import HttpResponse
from rest_framework import generics
from rest_framework.response import Response
from rest_framework import status
from .models import UserModel, UserProblem,UploadedImage,ZenCoins,Votes,AdminUser
from .serializers import UserModelSerializer,UserProblemSerializer,VotesSerializer,AdminUserSerializer
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
from django.core.exceptions import ObjectDoesNotExist
from django.views import View


#from django.contrib.gis.geos import Point
#from django.contrib.gis.db.models.functions import Distance

load_dotenv()
TWILIO_ACCOUNT_SID = os.getenv('TWILIO_ACCOUNT_SID')
TWILIO_AUTH_TOKEN = os.getenv('TWILIO_AUTH_TOKEN')
TWILIO_PHONE_NUMBER = os.getenv('TWILIO_PHONE_NUMBER')
distanceConstant = (3.141592653589793 / 180.0) * 6371
rf = Roboflow(api_key=os.getenv('api_key'))
project = rf.workspace().project("garbage_detection-wvzwv")
model = project.version(9).model

def fnDistanceCalculateFunction(x1,x2,y1,y2):
    result = sqrt(pow(x1-x2,2)+pow(y1-y2,2))
    return result*distanceConstant


def home(request):
    return HttpResponse("hello world")

#For creating the user id
class UserModelView(generics.CreateAPIView):
    serializer_class = UserModelSerializer

    def create(self, request, *args, **kwargs):
        try:
            
            user_id = request.data.get('user_id')
            print(user_id)
            email = request.data.get('email',None)
            phone_number = request.data.get('phone_number',None)
            print(phone_number)
            name = request.data.get('name',None)
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

                
                result = model.predict(f"media/user_problem_images/{image}", confidence=40, overlap=30).json()
                print("image is : ", result)
                # Check if the image is classified as garbage
                print(image)
                if len(result.get('predictions')) > 0:
                    user_problem = UserProblem.objects.create(
                        user=user, description=description, image=f"/user_problem_images/{image}",latitude=latitude,longitude=longitude,status=UserProblem.ProblemStatus.SUBMITTED
                    )
                    message=f"The garbage been detected in the location Latitude:{latitude},Longitude:{longitude}"
                    admin_user=AdminUser(phone_number="6302006736",admin_user="pujitha")
                    send_sms(admin_user,message)
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
    print(phone_number)
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
        print(input_latitude,input_longitude)

        # Create a LatLng object from the input latitude and longitude

        # Define the radius in kilometers
        radius_km = 100

        # Filter UserProblem instances within the specified radius
        user_problems = UserProblem.objects.all()  # Replace with your actual model queryset
        l=[]
        for problem in user_problems:
            if fnDistanceCalculateFunction(problem.latitude,input_latitude,input_longitude,problem.longitude)<radius_km:
                l.append([problem.latitude,problem.longitude])

        print(l)
        # Prepare data for the optimal route (you can customize this based on your requirements)
        data = {
            "visits": {
                f"order_{i+1}": {
                    "location": {
                        "name": f"Location {i+1}",
                        "lat": l[i][0],
                        "lng": l[i][1]
                    }
                } for i, problem in enumerate(l)
            },
            "fleet": {
                f"vehicle_{i+1}": {
                    "start_location": {
                        "id": "depot",
                        "name": "Depot",
                        "lat": input_latitude,
                        "lng": input_longitude
                    }
                } for i in range(2)
            }
        }

        # Assuming you have a Routific API URL and token
        routific_url = "https://api.routific.com/v1/vrp"
        routific_token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NWI0ZDlmZDcyMWQyYzAwMTg5MWMwY2MiLCJpYXQiOjE3MDYzNTExMDF9.PgF3RkZ8_Bxjs21EjVsiuck8pqx8oAVLoXkKAKa1nnI'

        # Convert data payload to bytes
        data_bytes = json.dumps(data).encode('utf-8')

        # Create a request object
        req = urllib.request.Request(routific_url, data_bytes, headers={'Content-Type': 'application/json', 'Authorization': 'bearer ' + routific_token})
        print(req)
        try:
            # Get route from Routific
            with urllib.request.urlopen(req) as response:
                res = response.read().decode('utf-8')

            return Response({"routes": json.loads(res)}, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
class LikesOfEachProblem(APIView):
    def post(self, request,*args, **kwargs):
        try:
            pid = request.data.get('pid', None)
            uid = request.data.get('uid', None)
            print("hii3")
            print(pid,uid)
            print("hii")
            problem_object =UserProblem.objects.get(pk=pid)
            votes_objects = Votes.objects.filter(problem=problem_object,user=UserModel.objects.get(user=uid))
            total_number_of_likes = len(votes_objects)
            print(request.user)
            user_liked = Votes.objects.filter(problem=problem_object, user=UserModel.objects.get(user=uid)).exists()
            if user_liked:
                user_liked = True
            else:
                user_liked = False

            response_data = {
                "votesCount": total_number_of_likes,
                "userLiked": user_liked
            }
            return Response(response_data, status=status.HTTP_200_OK)

        except UserProblem.DoesNotExist:
            return Response({"error": "Problem not found"}, status=status.HTTP_404_NOT_FOUND)

class ChangeCountofProblem(APIView):
    def post(self, request):
        uid = request.data.get('uid')
        pid = request.data.get('pid')
        count = int(request.data.get('count'))
        print(uid,pid,count)
        try:
            problem_object = UserProblem.objects.get(id=pid)
        except UserProblem.DoesNotExist:
            return Response({"error": "Problem not found"}, status=status.HTTP_404_NOT_FOUND)
        else:
            if count == -1:
                user_voted_obj = Votes.objects.filter(problem=UserProblem.objects.get(id=pid), user=UserModel.objects.get(user=uid))
                if user_voted_obj.exists():
                    user_voted_obj.delete()
            elif count == 1:
                vote_obj = Votes.objects.create(problem=UserProblem.objects.get(id=pid),user=UserModel.objects.get(user=uid))
                vote_obj.save()
                print("saved")

        return Response(status=status.HTTP_200_OK)


    
class AdminUserAPIView(APIView):
    def post(self, request):
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
                user_instance, created = AdminUser.objects.get_or_create(
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
    
    def get(self, request, *args, **kwargs):
        action = kwargs.get('action')
        if action == 'get_all_user_statuses':
            unique_statuses = UserProblem.objects.all()
            return render(request, 'user_statuses.html', {'statuses': unique_statuses})
        elif action == 'get_all_user_locations':
            user_locations = UserProblem.objects.all()
            
            return render(request, 'user_locations.html', {'locations': user_locations})
        elif action == 'get_all_user_images':
            user_images = UserProblem.objects.values('image')
            print(user_images)
            return render(request, 'user_images.html', {'user': user_images})
        elif action == 'get_all_user_admins':
            user_admins = AdminUser.objects.all()
            print(user_admins)
            return render(request, 'admin_user.html', {'user': user_admins})
        else:
            return render(request, 'admin_user.html')
    
        
    def get_all_user_images(self,request):
        try:
            print("hii")
            user = UserProblem.objects.all()
            print(user)
            return render(request, 'user_images.html', {'user': user})
        except ObjectDoesNotExist:
            return Response({"error": "No user images found"}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)    
        
    def get_all_user_statuses(self, request):
        try:
            unique_statuses = UserProblem.objects.values_list('status', flat=True).distinct()
            return Response({"statuses": list(unique_statuses)}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    def get_all_user_locations(self, request):
        try:
            user_locations = UserProblem.objects.values('latitude', 'longitude').distinct()
            return Response({"locations": list(user_locations)}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
class OptimalRoutesHTMLView(View):
    template_name = 'optimal_route.html'

    def get(self, request):
        return render(request, self.template_name)
    
class ZencoinFetchView(APIView):
    def get(self, request, user_id):
        try:
            user_zencoin = ZenCoins.objects.get(user=user_id)
            zencoin_data = {'balance': user_zencoin.zen_coins}
            return Response(zencoin_data, status=status.HTTP_200_OK)
        except ZenCoins.DoesNotExist:
            print(user_id)
            user=UserModel.objects.get(user=user_id)
            user_zencoin = ZenCoins.objects.create(user=user,zen_coins=0)
            zencoin_data = {'balance': user_zencoin.zen_coins}
            return Response(zencoin_data, status=status.HTTP_200_OK)
        
def admin_dashboard(request):
    # Assuming you have a User model with image, username, and status fields
    users = UserModel.objects.all()  # Replace YourUserModel with your actual model
    user_prob=UserProblem.objects.all()
    return render(request, 'admin_user.html', {'user_prob':user_prob})

def display_map(request):
    sample_points = [
            {'latitude': 21.1, 'longitude': 72.8},  # New York City
            {'latitude': 21.1699, 'longitude': 79.8311},  # Los Angeles
            {'latitude': 21.1702, 'longitude':  72.8311},  # Chicago
            {'latitude': 22.17, 'longitude': 73.83},  
        ]
    return render(request, 'display_map.html', {'location_points': sample_points})
        
