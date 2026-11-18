from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone

class Customer(models.Model):
    CUSTOMER_TYPES = [
        ('LOCAL', 'Local Resident'),
        ('VISITOR', 'Visitor'),
    ]
    username = models.CharField(max_length=100, unique=True, blank=True, null=True)
    name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True)
    city = models.CharField(max_length=100, blank=True)
    country = models.CharField(max_length=100, blank=True)
    customer_type = models.CharField(max_length=10, choices=CUSTOMER_TYPES, default='VISITOR')
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if self.email:
            self.email = self.email.strip().lower()
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

class Package(models.Model):
    LESSON_TYPES = [
        ('YOGA', 'Yoga'),
        ('MEDITATION', 'Meditation'),
    ]
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name='packages')
    package_type = models.CharField(max_length=20, choices=LESSON_TYPES, default='YOGA')
    total_lessons = models.IntegerField()
    remaining_lessons = models.IntegerField()
    purchase_date = models.DateField(default=timezone.now)
    price_paid = models.DecimalField(max_digits=6, decimal_places=2)

    def save(self, *args, **kwargs):
        if not self.pk:
            self.remaining_lessons = self.total_lessons
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.customer.name} - {self.total_lessons} {self.get_package_type_display()} pack ({self.remaining_lessons} left)"

class Lesson(models.Model):
    LESSON_TYPES = [
        ('YOGA', 'Yoga'),
        ('MEDITATION', 'Meditation'),
    ]
    lesson_type = models.CharField(max_length=20, choices=LESSON_TYPES, default='YOGA')
    date = models.DateField()
    time = models.TimeField(default='09:00')
    max_students = models.IntegerField(default=20)
    min_students = models.IntegerField(default=3)
    attendees = models.ManyToManyField(Customer, related_name='lessons_attended', blank=True)
    is_cancelled = models.BooleanField(default=False)
    notes = models.TextField(blank=True)

    def __str__(self):
        return f"{self.get_lesson_type_display()} on {self.date} at {self.time}"

    @property
    def attendee_count(self):
        return self.attendees.count()

    @property
    def is_in_future(self):
        from datetime import datetime
        now = timezone.now()
        # Combine date and time into a datetime object
        lesson_datetime = datetime.combine(self.date, self.time)
        # Make it timezone aware if settings.USE_TZ is True
        if timezone.is_aware(now):
            lesson_datetime = timezone.make_aware(lesson_datetime, timezone.get_current_timezone())
        return lesson_datetime > now

    @property
    def is_cancellable(self):
        from datetime import datetime, timedelta
        now = timezone.now()
        lesson_datetime = datetime.combine(self.date, self.time)
        if timezone.is_aware(now):
            lesson_datetime = timezone.make_aware(lesson_datetime, timezone.get_current_timezone())
        # Cancellable if more than 24 hours away
        return lesson_datetime > (now + timedelta(hours=24))

    @property
    def spots_left(self):
        return self.max_students - self.attendee_count

    @property
    def is_full(self):
        return self.attendee_count >= self.max_students

    @property
    def is_almost_full(self):
        # Either 3 or fewer spots left, or more than 85% full
        spots_left = self.max_students - self.attendee_count
        if self.is_full or self.is_cancelled:
            return False
        return spots_left <= 3 or (self.attendee_count / self.max_students) >= 0.85

    # Number of colours in the "booked" dot palette (.dot-0 … .dot-5 in lessons.html)
    BOOKED_DOT_COLOURS = 6

    @property
    def dot_index(self):
        """Colour of the booked-lesson dot: looks random, but stays the same for a lesson."""
        return (self.id * 7) % self.BOOKED_DOT_COLOURS

class Expense(models.Model):
    CATEGORIES = [
        ('GAS', 'Gas'),
        ('CAR', 'Car Maintenance'),
        ('ADS', 'Advertising'),
        ('TAX', 'Taxes (IVA/IRPF)'),
        ('SOCIAL', 'Social Security'),
        ('INSURANCE', 'Insurance'),
        ('MAT', 'Yoga Mats'),
        ('OTHER', 'Other'),
    ]
    date = models.DateField(default=timezone.now)
    category = models.CharField(max_length=10, choices=CATEGORIES)
    amount = models.DecimalField(max_digits=8, decimal_places=2)
    description = models.TextField()

    def __str__(self):
        return f"{self.get_category_display()} - {self.amount}€ on {self.date}"

class Inventory(models.Model):
    item_name = models.CharField(max_length=100, default='Yoga Mat')
    purchase_date = models.DateField()
    quantity = models.IntegerField()
    price_per_unit = models.DecimalField(max_digits=6, decimal_places=2)
    expected_lifetime_years = models.FloatField(default=1.5)

    def __str__(self):
        return f"{self.quantity}x {self.item_name} purchased on {self.purchase_date}"

    @property
    def replacement_date(self):
        from datetime import timedelta
        return self.purchase_date + timedelta(days=int(self.expected_lifetime_years * 365))
