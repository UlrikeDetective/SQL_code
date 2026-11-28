import os
import django
from datetime import date, timedelta

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'yoga_project.settings')
django.setup()

from core.models import Lesson

def seed_2027_lessons():
    start_date = date(2027, 1, 1)
    end_date = date(2027, 12, 31)
    
    current_date = start_date
    lessons_evening_created = 0
    
    while current_date <= end_date:

            
        # Yoga Lessons: Wednesday at 17:00 
        if current_date.weekday() in [0, 5]: # 5=saturday, 0=Monday
            Lesson.objects.get_or_create(
                date=current_date,
                time='11:00',
                lesson_type='YOGA',
                defaults={
                    'max_students': 20,
                    'min_students': 3,
                }
            )
            lessons_evening_created += 1
            
        current_date += timedelta(days=1)
    
    print(f"Successfully created {lessons_evening_created} evening Yoga lessons for 2027.")

if __name__ == "__main__":
    seed_2027_lessons()