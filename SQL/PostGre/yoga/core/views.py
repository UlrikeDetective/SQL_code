import calendar
from decimal import Decimal
from datetime import date, datetime, timedelta
from django.shortcuts import render, redirect, get_object_or_404
from django.urls import reverse
from django.contrib import messages
from django.core.exceptions import ValidationError
from django.core.validators import validate_email
from django.db.models import Max
from django.views.decorators.http import require_POST
from .models import Lesson, Customer, Package, Expense

def lessons_month_url(lesson):
    """URL of the calendar page showing the month of the given lesson."""
    return f"{reverse('lessons')}?year={lesson.date.year}&month={lesson.date.month}"


# Packages offered on the packages page. The price is looked up here on purchase,
# so the form only ever sends the key.
PACKAGE_OPTIONS = [
    {'key': 'yoga-1', 'label': 'Single Lesson', 'package_type': 'YOGA', 'lessons': 1, 'price': 15},
    {'key': 'yoga-3', 'label': '3 Lessons', 'package_type': 'YOGA', 'lessons': 3, 'price': 40},
    {'key': 'yoga-5', 'label': '5 Lessons', 'package_type': 'YOGA', 'lessons': 5, 'price': 55},
    {'key': 'yoga-10', 'label': '10 Lessons', 'package_type': 'YOGA', 'lessons': 10, 'price': 100},
    {'key': 'meditation-1', 'label': '1 Meditation Session', 'package_type': 'MEDITATION', 'lessons': 1, 'price': 5},
    {'key': 'meditation-5', 'label': '5 Meditation Sessions', 'package_type': 'MEDITATION', 'lessons': 5, 'price': 20},
]
PACKAGES_BY_KEY = {option['key']: option for option in PACKAGE_OPTIONS}


def log_in_customer(request, customer):
    """Remember the customer in the session (the site identifies customers by email)."""
    request.session['customer_email'] = customer.email
    request.session['customer_name'] = customer.name


def home(request):
    return render(request, 'home.html')

def lessons(request):
    # Get year and month from query params or default to current
    year = int(request.GET.get('year', date.today().year))
    month = int(request.GET.get('month', date.today().month))
    
    # Calculate previous and next months
    first_day = date(year, month, 1)
    prev_month_date = first_day - timedelta(days=1)
    next_month_date = (first_day + timedelta(days=32)).replace(day=1)
    
    # Get lessons for the current month
    month_lessons = Lesson.objects.filter(
        date__year=year, 
        date__month=month
    ).prefetch_related('attendees').order_by('date', 'time')
    
    # Identify lessons booked by the logged-in customer
    booked_lesson_ids = []
    session_email = request.session.get('customer_email')
    if session_email:
        try:
            customer = Customer.objects.get(email__iexact=session_email)
            booked_lesson_ids = list(month_lessons.filter(attendees=customer).values_list('id', flat=True))
        except Customer.DoesNotExist:
            pass

    # Create a dictionary of lessons grouped by day for the template
    lessons_by_day = {}
    for lesson in month_lessons:
        day = lesson.date.day
        if day not in lessons_by_day:
            lessons_by_day[day] = []
        lessons_by_day[day].append(lesson)
    
    # Generate the calendar days structure
    cal = calendar.Calendar(firstweekday=0) # Monday is 0
    month_days = cal.monthdays2calendar(year, month)
    
    month_name = calendar.month_name[month]
    
    context = {
        'year': year,
        'month': month,
        'month_name': month_name,
        'prev_year': prev_month_date.year,
        'prev_month': prev_month_date.month,
        'next_year': next_month_date.year,
        'next_month': next_month_date.month,
        'month_days': month_days,
        'lessons_by_day': lessons_by_day,
        'booked_lesson_ids': booked_lesson_ids,
        'today': date.today(),
    }
    
    return render(request, 'lessons.html', context)

def book_lesson(request, lesson_id):
    lesson = get_object_or_404(Lesson, pk=lesson_id)
    # Get email from session if logged in
    session_email = request.session.get('customer_email')
    is_booked = False
    
    if session_email:
        try:
            customer = Customer.objects.get(email__iexact=session_email)
            is_booked = lesson.attendees.filter(id=customer.id).exists()
        except Customer.DoesNotExist:
            pass
    
    if request.method == 'POST':
        email = request.POST.get('email', session_email).strip().lower()
        try:
            customer = Customer.objects.get(email__iexact=email)
            
            # "Log in" the user by saving to session
            request.session['customer_email'] = email
            request.session['customer_name'] = customer.name
            
            if not lesson.is_in_future:
                messages.error(request, "This lesson has already passed.")
            elif lesson.is_full:
                messages.error(request, "This lesson is already full.")
            elif lesson.is_cancelled:
                messages.error(request, "This lesson is cancelled.")
            elif lesson.attendees.filter(id=customer.id).exists():
                messages.warning(request, "You are already booked for this lesson.")
            else:
                # Check for packages of the correct type
                package = Package.objects.filter(
                    customer=customer, 
                    package_type=lesson.lesson_type,
                    remaining_lessons__gt=0
                ).order_by('purchase_date').first()
                
                if package:
                    package.remaining_lessons -= 1
                    package.save()
                    lesson.attendees.add(customer)
                    type_display = "yoga" if lesson.lesson_type == "YOGA" else "meditation"
                    messages.success(request, f"Successfully booked! You have {package.remaining_lessons} {type_display} sessions left in your pack.")
                else:
                    type_display = "Yoga" if lesson.lesson_type == "YOGA" else "Meditation"
                    messages.error(request, f"No active {type_display} package found. Please buy a package first.")
                    return redirect('packages')
            return redirect(lessons_month_url(lesson))
        except Customer.DoesNotExist:
            messages.error(request, "Customer with this email not found. Please ask the admin to add you.")
    
    return render(request, 'book_lesson.html', {
        'lesson': lesson,
        'calendar_url': lessons_month_url(lesson),
        'session_email': session_email,
        'is_booked': is_booked
    })

def cancel_booking(request, lesson_id):
    lesson = get_object_or_404(Lesson, pk=lesson_id)
    session_email = request.session.get('customer_email')
    
    if not session_email:
        messages.error(request, "You must be logged in to cancel a booking.")
        return redirect(lessons_month_url(lesson))
        
    try:
        customer = Customer.objects.get(email__iexact=session_email)
        
        if not lesson.attendees.filter(id=customer.id).exists():
            messages.error(request, "You don't have a booking for this lesson.")
            return redirect(lessons_month_url(lesson))
            
        if not lesson.is_cancellable:
            messages.error(request, "Lessons can only be cancelled more than 24 hours in advance.")
            return redirect('book_lesson', lesson_id=lesson.id)
            
        # Refund the lesson: Add 1 to the most recent package of the correct type
        package = Package.objects.filter(
            customer=customer,
            package_type=lesson.lesson_type
        ).order_by('-purchase_date').first()
        
        if package:
            package.remaining_lessons += 1
            package.save()
            lesson.attendees.remove(customer)
            type_display = "yoga" if lesson.lesson_type == "YOGA" else "meditation"
            messages.success(request, f"Booking cancelled. 1 {type_display} session has been added back to your balance ({package.remaining_lessons} left).")
        else:
            # This shouldn't happen if they booked, but as a fallback:
            lesson.attendees.remove(customer)
            messages.success(request, "Booking cancelled.")
            
        return redirect(lessons_month_url(lesson))
        
    except Customer.DoesNotExist:
        messages.error(request, "Customer not found.")
        return redirect(lessons_month_url(lesson))

def packages(request):
    return render(request, 'packages.html', {
        'session_email': request.session.get('customer_email'),
        'yoga_options': [o for o in PACKAGE_OPTIONS if o['package_type'] == 'YOGA'],
        'meditation_options': [o for o in PACKAGE_OPTIONS if o['package_type'] == 'MEDITATION'],
        'form': request.session.pop('signup_form', {}),
    })


@require_POST
def customer_login(request):
    email = request.POST.get('email', '').strip().lower()
    customer = Customer.objects.filter(email__iexact=email).first() if email else None
    if customer is None:
        messages.error(request, "We couldn't find an account with this email. New here? Create an account below.")
    else:
        log_in_customer(request, customer)
        messages.success(request, f"Welcome back, {customer.name}!")
    return redirect('packages')


@require_POST
def register(request):
    name = request.POST.get('name', '').strip()
    email = request.POST.get('email', '').strip().lower()
    phone = request.POST.get('phone', '').strip()
    city = request.POST.get('city', '').strip()

    error = None
    if not name:
        error = "Please enter your name."
    else:
        try:
            validate_email(email)
        except ValidationError:
            error = "Please enter a valid email address."
    if error is None and Customer.objects.filter(email__iexact=email).exists():
        error = "There is already an account with this email. Please log in instead."

    if error:
        messages.error(request, error)
        # Keep what was typed so the visitor doesn't have to start over
        request.session['signup_form'] = {'name': name, 'email': email, 'phone': phone, 'city': city}
        return redirect('packages')

    customer = Customer.objects.create(
        name=name,
        email=email,
        phone=phone,
        city=city,
        customer_type='LOCAL' if city.lower() == 'tarifa' else 'VISITOR',
    )
    log_in_customer(request, customer)
    messages.success(request, f"Welcome, {customer.name}! Your account is ready. Now choose a package.")
    return redirect('packages')


@require_POST
def buy_package(request):
    email = request.session.get('customer_email')
    customer = Customer.objects.filter(email__iexact=email).first() if email else None
    if customer is None:
        messages.error(request, "Please log in or create an account before buying a package.")
        return redirect('packages')

    option = PACKAGES_BY_KEY.get(request.POST.get('package', ''))
    if option is None:
        messages.error(request, "Please choose a package.")
        return redirect('packages')

    Package.objects.create(
        customer=customer,
        package_type=option['package_type'],
        total_lessons=option['lessons'],
        remaining_lessons=option['lessons'],
        price_paid=option['price'],
    )
    messages.success(request, f"Successfully purchased {option['label']} for {option['price']}€.")
    return redirect('lessons')

def check_balance(request):
    packages = []
    # Try to get email from session first
    email = request.session.get('customer_email', "")
    
    if request.method == 'POST':
        email = request.POST.get('email', '').strip().lower()
        
    if email:
        try:
            customer = Customer.objects.get(email__iexact=email)
            # Update session if they manually searched and found themselves
            request.session['customer_email'] = email
            request.session['customer_name'] = customer.name
            
            packages = Package.objects.filter(customer=customer).order_by('-purchase_date')
            if not packages.exists() and request.method == 'POST':
                messages.info(request, "No packages found for this email.")
        except Customer.DoesNotExist:
            if request.method == 'POST':
                messages.error(request, "Customer with this email not found.")
            
    return render(request, 'check_balance.html', {'packages': packages, 'email': email})

def logout(request):
    # Clear customer session data
    if 'customer_email' in request.session:
        del request.session['customer_email']
    if 'customer_name' in request.session:
        del request.session['customer_name']
    messages.info(request, "You have been logged out.")
    return redirect('home')

def dashboard(request):
    # Summary data for the owner
    customers_count = Customer.objects.count()
    lessons_count = Lesson.objects.count()
    
    # Get today's lessons
    today_lessons = Lesson.objects.filter(date=date.today()).order_by('time')
    
    # Tarifa Locals: Customers from Tarifa and their furthest future booking
    tarifa_locals = Customer.objects.filter(
        city__iexact='Tarifa'
    ).annotate(
        furthest_lesson_date=Max('lessons_attended__date')
    ).filter(
        furthest_lesson_date__isnull=False
    ).order_by('-furthest_lesson_date')
    
    # Profit calculation (Total all time)
    total_expenses = sum(e.amount for e in Expense.objects.all())
    total_income = sum(p.price_paid for p in Package.objects.all())
    
    # --- Monthly Financial Overview (Current Year) ---
    current_year = date.today().year
    financial_data = {} 
    
    # Initialize months 1-12
    for m in range(1, 13):
        financial_data[m] = {
            'month_name': calendar.month_name[m],
            'gross_income': Decimal('0.00'),
            'expenses': Decimal('0.00'),
            'social_security': Decimal('0.00'),
        }
    
    # Aggregate Income (Packages)
    packages = Package.objects.filter(purchase_date__year=current_year)
    for p in packages:
        financial_data[p.purchase_date.month]['gross_income'] += p.price_paid
        
    # Aggregate Expenses
    expenses = Expense.objects.filter(date__year=current_year)
    for e in expenses:
        if e.category == 'SOCIAL':
             financial_data[e.date.month]['social_security'] += e.amount
        elif e.category == 'TAX':
             # Skip tax payments in P&L calculation as they are payments of liability
             pass 
        else:
             financial_data[e.date.month]['expenses'] += e.amount

    # Calculate Taxes & Net Profit per month
    monthly_overview = []
    
    for m in range(1, 13):
        data = financial_data[m]
        
        gross = data['gross_income']
        # IVA Rate: 21% (included in gross price) -> Base = Price / 1.21
        net_revenue = gross / Decimal('1.21')
        iva = gross - net_revenue
        
        # Deductible Expenses (Net expenses + Social Security)
        # Assuming expenses entered are net deductible amounts
        total_deductible = data['expenses'] + data['social_security']
        
        # Operating Profit (Before IRPF)
        operating_profit = net_revenue - total_deductible
        
        # IRPF (20% on positive profit)
        irpf = operating_profit * Decimal('0.20') if operating_profit > 0 else Decimal('0.00')
        
        # Final Net Profit
        final_profit = operating_profit - irpf
        
        # Round for display
        data['net_revenue'] = round(net_revenue, 2)
        data['iva'] = round(iva, 2)
        data['operating_profit'] = round(operating_profit, 2)
        data['irpf'] = round(irpf, 2)
        data['final_profit'] = round(final_profit, 2)
        
        # Only add to list if there's activity or up to current month
        if m <= date.today().month or gross > 0 or data['expenses'] > 0:
            monthly_overview.append(data)
    
    context = {
        'customers_count': customers_count,
        'lessons_count': lessons_count,
        'today_lessons': today_lessons,
        'active_tarifa_locals': tarifa_locals,
        'total_expenses': total_expenses,
        'total_income': total_income,
        'monthly_overview': monthly_overview,
        'current_year': current_year,
    }
    return render(request, 'dashboard.html', context)

def mark_attendance(request, lesson_id):
    lesson = get_object_or_404(Lesson, pk=lesson_id)
    attendees = lesson.attendees.all()
    
    if request.method == 'POST':
        # Attendance logic can be expanded here if we wanted to track "show" vs "no-show"
        # For now, it's a confirmation view of who booked.
        messages.success(request, f"Attendance for {lesson} confirmed.")
        return redirect('dashboard')
        
    return render(request, 'mark_attendance.html', {
        'lesson': lesson,
        'attendees': attendees
    })
