from django.urls import path
from . import views
from .views import UserModelView,ImageUploadView,IncreaseCoinsAPIView,UserExistsAPIView,UserProblemListAPIView,OptimalRoutesAPIView
from django.conf import settings
from django.conf.urls.static import static
from django.conf import settings


urlpatterns = [
    path('',views.home,name='home'),
    path('api/user/', UserModelView.as_view(), name='my-model'),
    path('api/upload/', ImageUploadView.as_view(), name='image-upload'),
    path('api/increase_coins/<str:user_id>/', IncreaseCoinsAPIView.as_view(), name='increase_coins_api'),
    path('api/user_exists/<str:user_id>/', UserExistsAPIView.as_view(), name='user_exists_api'),
    path('api/user-problems/', UserProblemListAPIView.as_view(), name='user-problem-list'),
    path('api/optimal_points/', OptimalRoutesAPIView.as_view(), name='user-problem-list'),
]


urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)