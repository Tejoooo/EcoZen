from django.db import models

class UserModel(models.Model):
    user = models.TextField(primary_key=True, unique=True)
    phone_number = models.CharField(max_length=15,null=True)
    email = models.EmailField(unique=True,null=True, blank=True)
    name = models.CharField(max_length=255,null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    city = models.CharField(max_length=255, blank=True, null=True)
    state = models.CharField(max_length=255, blank=True, null=True)
    pincode = models.CharField(max_length=10, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
class UserProblem(models.Model):
    class ProblemStatus(models.TextChoices):
        SUBMITTED = 'Submitted', 'Submitted'
        IN_PROGRESS = 'In Progress', 'In Progress'
        SOLVED = 'Solved', 'Solved'
    user = models.ForeignKey(UserModel, related_name='images', on_delete=models.CASCADE)
    description = models.TextField()
    status = models.CharField(max_length=20, choices=ProblemStatus.choices, default=ProblemStatus.SUBMITTED)
    image = models.ImageField(upload_to='user_problem_images/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    latitude = models.FloatField()
    longitude = models.FloatField()

class ZenCoins(models.Model):
    user = models.OneToOneField(UserModel, primary_key=True, on_delete=models.CASCADE)
    zen_coins = models.PositiveIntegerField(default=0)

    def __str__(self):
        return f"{self.user} - {self.zen_coins} Zen Coins"
    
class UploadedImage(models.Model):
    image = models.ImageField(upload_to='user_problem_images/')

class Votes(models.Model):
    user = models.ForeignKey(UserModel, on_delete=models.CASCADE)
    problem = models.ForeignKey(UserProblem, on_delete=models.CASCADE)
    votes = models.IntegerField(default=0)

    class Meta:
        # Define a composite primary key
        unique_together = ('user', 'problem')

class AdminUser(models.Model):
    admin_user = models.TextField(primary_key=True, unique=True)
    phone_number = models.CharField(max_length=10)
    email = models.EmailField(unique=True,null=True, blank=True)
    name = models.CharField(max_length=255,null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    city = models.CharField(max_length=255, blank=True, null=True)
    state = models.CharField(max_length=255, blank=True, null=True)
    pincode = models.CharField(max_length=10, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


