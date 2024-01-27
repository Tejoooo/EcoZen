from django.urls import path
from . import views
from .views import UserModelView,ImageUploadView

urlpatterns = [
    path('',views.home,name='home'),
    path('api/user/<str:user_id>/', UserModelView.as_view(), name='my-model'),
    path('api/upload/', ImageUploadView.as_view(), name='image-upload'),
]