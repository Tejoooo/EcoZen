from rest_framework import serializers
from .models import UserModel,UserProblem,AdminUser

class UserModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserModel
        fields = '__all__'

class UserProblemSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProblem
        fields = ['user','description','latitude','longitude','image']
        
class AdminUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = AdminUser
        fields = '__all__'