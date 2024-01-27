from django.contrib import admin
from .models import UserModel,UserProblem,ZenCoins,UploadedImage
# Register your models here.

admin.site.register(UserModel)
admin.site.register(UserProblem)
admin.site.register(ZenCoins)
admin.site.register(UploadedImage)



