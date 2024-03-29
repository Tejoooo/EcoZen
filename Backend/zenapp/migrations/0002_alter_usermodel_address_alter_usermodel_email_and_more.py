# Generated by Django 4.2.9 on 2024-01-27 14:20

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("zenapp", "0001_initial"),
    ]

    operations = [
        migrations.AlterField(
            model_name="usermodel",
            name="address",
            field=models.TextField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name="usermodel",
            name="email",
            field=models.EmailField(blank=True, max_length=254, null=True, unique=True),
        ),
        migrations.AlterField(
            model_name="usermodel",
            name="name",
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
        migrations.AlterField(
            model_name="usermodel",
            name="phone_number",
            field=models.CharField(max_length=15, null=True),
        ),
    ]
