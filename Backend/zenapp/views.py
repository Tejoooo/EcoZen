from django.shortcuts import render
from django.http import HttpResponse
from rest_framework import generics
from rest_framework.response import Response
from rest_framework import status
from .models import UserModel, UserProblem, UserProblemImage,UploadedImage
from .serializers import UserModelSerializer,UserProblemSerializer
from rest_framework.views import APIView
from rest_framework import status
from roboflow import Roboflow
from dotenv import load_dotenv
import os

load_dotenv()

def home(request):
    return HttpResponse("hello world")

#For creating the user id
class UserModelView(generics.CreateAPIView):
    serializer_class = UserModelSerializer
    def create(self, request, *args, **kwargs):
        # Retrieve Firebase user ID from the request
        user_id = self.kwargs.get('user_id',None)
        print(self.kwargs)
        print(user_id)
        user_id=int(user_id)
        if user_id:
            user_identifier, created = UserModel.objects.get_or_create(user=user_id)

            if created:
                return Response({"detail": "User ID created successfully."}, status=status.HTTP_201_CREATED)
            else:
                return Response({"detail": "User ID already exists."}, status=status.HTTP_200_OK)

        return Response({"detail": "Firebase user ID not found in the request."}, status=status.HTTP_400_BAD_REQUEST)
    
# For Image uploaded by users
class ImageUploadView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = UserProblemSerializer(data=request.data)

        if serializer.is_valid():
            print(serializer.validated_data)
            user = serializer.validated_data.get('user')
            description = serializer.validated_data['description']
            image = request.FILES.get('image', None)
            UploadedImage.objects.create(image=image)

            if image:
                rf = Roboflow(api_key=os.getenv('api_key'))
                project = rf.workspace().project("garbage_detection-wvzwv")
                model = project.version(9).model
                result = model.predict(f"user_problem_images/{image}", confidence=40, overlap=30).json()

                # Check if the image is classified as garbage
                if len(result.get('predictions')) > 0:
                    user_problem = UserProblem.objects.create(
                        user=user, description=description, status=UserProblem.ProblemStatus.TAKEN
                    )
                    UserProblemImage.objects.create(user_problem=user_problem, image=image)
                    # Save the data to the database

                    return Response({'message': 'Image is classified as garbage. Data stored.'}, status=status.HTTP_201_CREATED)
                else:
                    #image=UploadedImage.objects.get(image=image)
                    #image.delete()
                    return Response({'message': 'Image is not classified as garbage. Data not stored.'}, status=status.HTTP_400_BAD_REQUEST)
            else:
                return Response({'message': 'No image file provided.'}, status=status.HTTP_400_BAD_REQUEST)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)




