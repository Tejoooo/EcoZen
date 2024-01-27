from django.db import models

class UserModel(models.Model):
    user = models.IntegerField(primary_key=True, unique=True)
    def __str__(self):
        return f"{self.user}"
    
class UserProblem(models.Model):
    class ProblemStatus(models.TextChoices):
        TAKEN = 'Taken', 'Taken'
        IN_PROGRESS = 'In Progress', 'In Progress'
        SOLVED = 'Solved', 'Solved'
    user = models.ForeignKey(UserModel, related_name='images', on_delete=models.CASCADE)
    description = models.TextField()
    status = models.CharField(max_length=20, choices=ProblemStatus.choices, default=ProblemStatus.TAKEN)
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
class UserProblemImage(models.Model):
    user_problem = models.ForeignKey(UserProblem, related_name='images', on_delete=models.CASCADE)
    image = models.ImageField(upload_to='user_problem_images/')
    uploaded_at = models.DateTimeField(auto_now_add=True)


class ZenCoins(models.Model):
    user = models.OneToOneField(UserModel, primary_key=True, on_delete=models.CASCADE)
    zen_coins = models.PositiveIntegerField(default=0)

    def __str__(self):
        return f"{self.user} - {self.zen_coins} Zen Coins"
    
class UploadedImage(models.Model):
    image = models.ImageField(upload_to='user_problem_images/')