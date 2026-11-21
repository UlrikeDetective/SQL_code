from django.test import TestCase, Client
from django.utils import timezone
from django.urls import reverse
from .models import Lesson, Customer, Package
from datetime import date, time, timedelta

class LessonModelTest(TestCase):
    def test_is_in_future(self):
        # Past lesson
        past_date = date.today() - timedelta(days=1)
        past_lesson = Lesson.objects.create(date=past_date, time=time(9, 0))
        self.assertFalse(past_lesson.is_in_future)

        # Future lesson
        future_date = date.today() + timedelta(days=1)
        future_lesson = Lesson.objects.create(date=future_date, time=time(9, 0))
        self.assertTrue(future_lesson.is_in_future)

class BookingViewTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.customer = Customer.objects.create(
            name="Test User",
            email="test@example.com",
            customer_type='VISITOR'
        )
        self.package = Package.objects.create(
            customer=self.customer,
            total_lessons=5,
            remaining_lessons=5,
            price_paid=55.00
        )

    def test_book_past_lesson_fails(self):
        past_date = date.today() - timedelta(days=1)
        lesson = Lesson.objects.create(date=past_date, time=time(9, 0))
        
        response = self.client.post(reverse('book_lesson', args=[lesson.id]), {
            'email': 'test@example.com'
        })
        
        # Should redirect back to lessons (or stay on same page with error, based on current view logic it redirects to lessons)
        self.assertEqual(response.status_code, 302)
        self.assertEqual(lesson.attendees.count(), 0)
        
        # Follow redirect to check messages
        response = self.client.get(response.url)
        self.assertContains(response, "This lesson has already passed.")

    def test_book_future_lesson_succeeds(self):
        future_date = date.today() + timedelta(days=1)
        lesson = Lesson.objects.create(date=future_date, time=time(9, 0))
        
        response = self.client.post(reverse('book_lesson', args=[lesson.id]), {
            'email': 'test@example.com'
        })
        
        self.assertEqual(response.status_code, 302)
        self.assertEqual(lesson.attendees.count(), 1)
        
        # Follow redirect to check messages
        response = self.client.get(response.url)
        self.assertContains(response, "Successfully booked!")


class PackagesAccountTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.customer = Customer.objects.create(name="Ana", email="ana@example.com")

    def test_login_with_known_email_sets_session(self):
        response = self.client.post(reverse('customer_login'), {'email': 'ANA@example.com'})
        self.assertRedirects(response, reverse('packages'))
        self.assertEqual(self.client.session['customer_email'], 'ana@example.com')

    def test_login_with_unknown_email_fails(self):
        self.client.post(reverse('customer_login'), {'email': 'nobody@example.com'})
        self.assertNotIn('customer_email', self.client.session)

    def test_register_creates_customer_and_logs_in(self):
        response = self.client.post(reverse('register'), {
            'name': 'Lucía', 'email': 'Lucia@Example.com', 'phone': '', 'city': 'Tarifa',
        })
        self.assertRedirects(response, reverse('packages'))
        customer = Customer.objects.get(email='lucia@example.com')
        self.assertEqual(customer.customer_type, 'LOCAL')
        self.assertEqual(self.client.session['customer_email'], 'lucia@example.com')

    def test_register_with_existing_email_is_rejected(self):
        self.client.post(reverse('register'), {'name': 'Other', 'email': 'ana@example.com'})
        self.assertEqual(Customer.objects.filter(email='ana@example.com').count(), 1)
        self.assertNotIn('customer_email', self.client.session)

    def test_register_requires_name_and_valid_email(self):
        self.client.post(reverse('register'), {'name': '', 'email': 'x@example.com'})
        self.client.post(reverse('register'), {'name': 'X', 'email': 'not-an-email'})
        self.assertFalse(Customer.objects.filter(name='X').exists())
        self.assertFalse(Customer.objects.filter(email='x@example.com').exists())

    def test_buy_requires_login(self):
        self.client.post(reverse('buy_package'), {'package': 'yoga-3'})
        self.assertFalse(Package.objects.exists())

    def test_buy_uses_server_side_price(self):
        self.client.post(reverse('customer_login'), {'email': 'ana@example.com'})
        response = self.client.post(reverse('buy_package'), {'package': 'meditation-5', 'price': '1'})
        self.assertRedirects(response, reverse('lessons'))
        package = Package.objects.get(customer=self.customer)
        self.assertEqual((package.package_type, package.total_lessons, package.price_paid), ('MEDITATION', 5, 20))

    def test_buy_rejects_unknown_package(self):
        self.client.post(reverse('customer_login'), {'email': 'ana@example.com'})
        self.client.post(reverse('buy_package'), {'package': 'yoga-999'})
        self.assertFalse(Package.objects.exists())

    def test_packages_page_shows_one_menu_with_prices(self):
        response = self.client.get(reverse('packages'))
        self.assertContains(response, 'name="package"', count=1)
        self.assertContains(response, 'Single Lesson')
        self.assertContains(response, '15€')
        self.assertNotContains(response, 'Drop-in session')
