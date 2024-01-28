from django.contrib import admin
from .models import UserModel,UserProblem,UserProblemImage,ZenCoins,UploadedImage
from .models import UserModel,UserProblem,ZenCoins,UploadedImage,Votes,AdminUser
from .models import UserModel,UserProblem,ZenCoins,UploadedImage,AdminUser,Votes
# Register your models here.

admin.site.register(UserModel)
admin.site.register(UserProblemImage)
admin.site.register(UserProblem)
admin.site.register(ZenCoins)
admin.site.register(UploadedImage)
admin.site.register(AdminUser)
admin.site.register(Votes)



