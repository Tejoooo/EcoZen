from rest_framework import serializers
from .models import UserModel,UserProblem,Votes,AdminUser

class UserModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserModel
        fields = '__all__'

class UserProblemSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProblem
        fields = ['user','description','latitude','longitude','image','pk']
        
class AdminUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = AdminUser
        fields = '__all__'
        fields = ['user','description','latitude','longitude','image','pk']

class VotesSerializer(serializers.ModelSerializer):
    class Meta:
        model = Votes
        fields = ['user', 'problem']
    def create(self, validated_data):
        """
        Create and return a new Votes instance, given the validated data.
        """
        return Votes.objects.create(**validated_data)
