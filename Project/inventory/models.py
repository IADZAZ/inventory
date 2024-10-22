from django.db import models

# Create your models here.
class Product(models.Model):
    name = models.CharField("Name", max_length=240)