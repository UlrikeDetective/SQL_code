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
    lessons_created = 0
    meditation_created = 0
    lessons_evening_created = 0
    
    while current_date <= end_date:
        # Yoga Lessons: Mon-Sat at 09:00
        # 0=Monday, 1=Tuesday, ..., 5=Saturday, 6=Sunday
        if current_date.weekday() < 6:
            Lesson.objects.get_or_create(
                date=current_date,
                time='09:00',
                lesson_type='YOGA',
                defaults={
                    'max_students': 20,
                    'min_students': 3,
                }
            )
            lessons_created += 1
            
        # Meditation Sessions: Monday, Wednesday and Thursday at 19:15 (7:15 PM)
        if current_date.weekday() in [0, 2, 3]: # 0=Monday, 2=Wednesday, 3=Thursday
            Lesson.objects.get_or_create(
                date=current_date,
                time='19:15',
                lesson_type='MEDITATION',
                defaults={
                    'max_students': 20,
                    'min_students': 3,
                }
            )
            meditation_created += 1
        
        # Yoga Lessons: Monday, Wednesday and Thursday at 18:00
        if current_date.weekday() in [0, 2, 3]: # 0=Monday, 2=Wednesday, 3=Thursday
            Lesson.objects.get_or_create(
                date=current_date,
                time='18:00',
                lesson_type='YOGA',
                defaults={
                    'max_students': 20,
                    'min_students': 3,
                }
            )
            lessons_evening_created += 1
            
        current_date += timedelta(days=1)
            
    
    print(f"Successfully created {lessons_created} Yoga lessons for 2027.")
    print(f"Successfully created {meditation_created} Meditation sessions for 2027.")
    print(f"Successfully created {lessons_evening_created} evening Yoga lessons for 2027.")

if __name__ == "__main__":
    seed_2027_lessons()
