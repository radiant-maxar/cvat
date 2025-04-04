# Generated by Django 4.2.1 on 2023-06-23 19:26

from django.db import migrations, models


def forwards_func(apps, schema_editor):
    Issue = apps.get_model("engine", "Issue")

    issues = Issue.objects.all()
    for issue in issues:
        issue.updated_date = issue.created_date

    Issue.objects.bulk_update(issues, fields=['updated_date'], batch_size=500)

class Migration(migrations.Migration):
    dependencies = [
        ("engine", "0071_annotationguide_asset"),
    ]

    operations = [
        migrations.RunPython(
            code=forwards_func,
        ),
        migrations.AlterField(
            model_name="issue",
            name="updated_date",
            field=models.DateTimeField(auto_now=True),
        ),
    ]
