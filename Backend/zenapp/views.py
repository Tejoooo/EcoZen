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


load_dotenv()

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
    def post(self, request, *args, **kwargs):
        serializer = UserProblemSerializer(data=request.data)

        if serializer.is_valid():
            try:
                user = serializer.validated_data.get('user')
                description = serializer.validated_data['description']
                image = request.FILES.get('image', None)

                # Check if image is provided
                if not image:
                    return Response({'message': 'No image file provided.'}, status=status.HTTP_400_BAD_REQUEST)

                # Save the image
                UploadedImage.objects.create(image=image)

                rf = Roboflow(api_key=os.getenv('api_key'))
                project = rf.workspace().project("garbage_detection-wvzwv")
                model = project.version(9).model
                result = model.predict(f"user_problem_images/{image}", confidence=40, overlap=30).json()

                # Check if the image is classified as garbage
                if len(result.get('predictions')) > 0:
                    user_problem = UserProblem.objects.create(
                        user=user, description=description, image=image, status=UserProblem.ProblemStatus.SUBMITTED
                    )
                    return Response({'message': 'Image is classified as garbage. Data stored.'}, status=status.HTTP_201_CREATED)
                else:
                    # Delete the image if it's not classified as garbage
                    try:
                        image_instance = UploadedImage.objects.get(image=f"user_problem_images/{image}")
                        image_instance.delete()
                        print(f"Image {image} deleted successfully.")
                    except UploadedImage.DoesNotExist:
                        print(f"Image {image} not found.")

                    return Response({'message': 'Image is not classified as garbage. Data not stored.'}, status=status.HTTP_400_BAD_REQUEST)
            
            except Exception as e:
                return Response({'message': f"An error occurred: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

class IncreaseCoinsAPIView(APIView):
    def post(self, request, user_id):
        user = get_object_or_404(UserModel, user=user_id)
        zen_coins, created = ZenCoins.objects.get_or_create(user=user)
        zen_coins.zen_coins += 1
        zen_coins.save()
        return Response({"detail": "Zen Coins increased successfully."}, status=status.HTTP_200_OK)
    





