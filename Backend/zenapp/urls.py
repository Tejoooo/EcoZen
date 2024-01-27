from django.urls import path
from . import views
from .views import UserModelView,ImageUploadView,IncreaseCoinsAPIView

urlpatterns = [
    path('',views.home,name='home'),
    path('api/user/', UserModelView.as_view(), name='my-model'),
    path('api/upload/', ImageUploadView.as_view(), name='image-upload'),
    path('api/increase_coins/<str:user_id>/', IncreaseCoinsAPIView.as_view(), name='increase_coins_api'),
]