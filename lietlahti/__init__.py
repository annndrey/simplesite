from pyramid.authentication import AuthTktAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.config import Configurator
from pyramid.session import UnencryptedCookieSessionFactoryConfig
from sqlalchemy import engine_from_config
from pyramid.i18n import TranslationStringFactory

from .models import (
    DBSession,
    Base,
	Post,
	User,
	Article
    )

_ = TranslationStringFactory('lietlahti')
sessionfactory = UnencryptedCookieSessionFactoryConfig('t,fysdhjn')
authn_policy = AuthTktAuthenticationPolicy( 'secret')
authz_policy = ACLAuthorizationPolicy()

def main(global_config, **settings):
	""" This function returns a Pyramid WSGI application.
	"""
	engine = engine_from_config(settings, 'sqlalchemy.')
	DBSession.configure(bind=engine)
	Base.metadata.bind = engine
	config = Configurator(settings=settings, session_factory=sessionfactory)
	config.add_translation_dirs('lietlahti:locale/')
	config.set_locale_negotiator(my_locale_negotiator)
	config.add_subscriber('lietlahti.subscribers.add_renderer_globals',
						  'pyramid.events.BeforeRender')
	config.add_subscriber('lietlahti.subscribers.add_localizer',
						  'pyramid.events.NewRequest')
	config.include('pyramid_mako')
	config.include('pyramid_mailer')
	config.set_authentication_policy(authn_policy)
	config.set_authorization_policy(authz_policy)
	config.add_static_view('static', 'static', cache_max_age=3600)
	config.add_route('home', '/discuss')
	config.add_route('home_slash', '/discuss/')
	config.add_route('home:page', '/discuss/{page:\d+}')
	config.add_route('login', '/login')
	config.add_route('oauthwrapper', '/oauth')
	config.add_route('passrestore', '/passrestore')
	config.add_route('oauthfacebook', '/oauthfb')
	config.add_route('oauthgoogle', '/oauthgplus')
	config.add_route('oauthtwitter', '/oauthtw/{email}')
	config.add_route('oauthreg', '/oauthreg')
	config.add_route('language', '/language')
	config.add_route('edit', '/edit/{pub:\w+}/{id:\d+}')
	config.add_route('newarticle', '/newarticle')
	config.add_route('article', '/article/{url:\w+}')
	config.add_route('remove', '/remove/{pub:\w+}/{id:\d+}')
	config.add_route('newpost', '/newpost')
	config.add_route('logout', '/logout')
	config.add_route('upload', '/upload')
	config.add_route('main', '/')
	config.scan()
	return config.make_wsgi_app()


def my_locale_negotiator(request):
	locale_name = request.session.get('lang')
	return locale_name
