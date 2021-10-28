#!/usr/bin/env bash
# This script must not be used for production. Migrating, collecting static
# data, check database connection should be done by different jobs in
# at a different layer.

set -e

# bash scripts/tcp-port-wait.sh $DATABASE_HOST $DATABASE_PORT

echo $(date -u) "- Migrating"
python manage.py makemigrations
python manage.py migrate

echo "Creating admin user"
python manage.py shell -c "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@humanitec.com', 'admin') if not User.objects.filter(email='admin@humanitec.com').count() else 'Do nothing'"

echo $(date -u) "- Load Initial Data"
python manage.py loadinitialdata

echo "Starting celery worker"
celery_cmd="celery -A tola worker -l info -f celery.log"
$celery_cmd &

echo $(date -u) "- Running the server"
if [ "$nginx" == "true" ]; then
    PYTHONUNBUFFERED=1 gunicorn -b 0.0.0.0:8080 tola.wsgi --reload
else
    PYTHONUNBUFFERED=1 python manage.py runserver 0.0.0.0:8080
fi