from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('lessons/', views.lessons, name='lessons'),
    path('lessons/book/<int:lesson_id>/', views.book_lesson, name='book_lesson'),
    path('lessons/cancel/<int:lesson_id>/', views.cancel_booking, name='cancel_booking'),
    path('packages/', views.packages, name='packages'),
    path('packages/buy/', views.buy_package, name='buy_package'),
    path('login/', views.customer_login, name='customer_login'),
    path('register/', views.register, name='register'),
    path('packages/check-balance/', views.check_balance, name='check_balance'),
    path('logout/', views.logout, name='logout'),
    path('dashboard/', views.dashboard, name='dashboard'),
    path('dashboard/attendance/<int:lesson_id>/', views.mark_attendance, name='mark_attendance'),
]
