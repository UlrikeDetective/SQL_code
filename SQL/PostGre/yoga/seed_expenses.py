import os
import django
from datetime import date
from decimal import Decimal

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'yoga_project.settings')
django.setup()

from core.models import Expense

def seed_october_expenses():
    # Adding October 2026 Social Security & other expenses
    october_expenses = [
        {'date': date(2026, 10, 5), 'category': 'SOCIAL', 'amount': Decimal('230.00'), 'description': 'RETA Social Security October'},
        {'date': date(2026, 10, 10), 'category': 'ADS', 'amount': Decimal('75.00'), 'description': 'Instagram Ads - October Promo'},
        {'date': date(2026, 10, 15), 'category': 'GAS', 'amount': Decimal('70.00'), 'description': 'Gas to Tarifa Beach'},
        {'date': date(2026, 10, 20), 'category': 'INSURANCE', 'amount': Decimal('30.00'), 'description': 'Professional Liability Insurance (Monthly)'},
    ]
    
    for ex in october_expenses:
        Expense.objects.get_or_create(
            date=ex['date'],
            category=ex['category'],
            amount=ex['amount'],
            description=ex['description']
        )
    
    print(f"Successfully seeded {len(october_expenses)} expenses for October 2026.")

if __name__ == "__main__":
    seed_october_expenses()
