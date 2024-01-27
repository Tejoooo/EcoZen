from django.contrib import admin
from .models import UserModel,UserProblem,UserProblemImage,ZenCoins,UploadedImage
# Register your models here.

admin.site.register(UserModel)
admin.site.register(UserProblemImage)
admin.site.register(UserProblem)
admin.site.register(ZenCoins)
admin.site.register(UploadedImage)



