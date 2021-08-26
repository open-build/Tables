from django.template.defaultfilters import slugify
from factory import DjangoModelFactory, lazy_attribute


class User(DjangoModelFactory):
    class Meta:
        model = 'auth.User'
        django_get_or_create = ('username',)

    first_name = 'Thom'
    last_name = 'Yorke'
    username = lazy_attribute(lambda o: slugify(o.first_name + '.' +
                                                o.last_name))
    email = lazy_attribute(lambda o: o.username + "@testenv.com")


class UserSocialAuth(DjangoModelFactory):
    class Meta:
        model = 'social_django.UserSocialAuth'
