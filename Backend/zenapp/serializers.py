from rest_framework import serializers
from .models import UserModel,UserProblem

class UserModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserModel
        fields = '__all__'

class UserProblemSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProblem
        fields = ['user','description']