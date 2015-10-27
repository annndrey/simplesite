#!/usr/bin/env python
# -*- coding: utf-8

import hashlib

from rauth import OAuth2Service, OAuth1Service
from rauth.utils import parse_utf8_qsl

from pyramid.view import (
    notfound_view_config,
    forbidden_view_config,
    view_config
)
from pyramid.security import (
    authenticated_userid,
    forget,
    remember
)
from pyramid.httpexceptions import (
    HTTPForbidden,
    HTTPFound,
    HTTPNotFound,
    HTTPSeeOther
)

from pyramid.i18n import (
    TranslationStringFactory,
    get_localizer,
    get_locale_name
)

from pyramid_mailer import get_mailer
from pyramid_mailer.message import Message

import os 
import uuid
import json
import codecs
import datetime, time
import sched
import transaction
import re 
from urllib.request import urlopen
from pyramid.response import Response
from sqlalchemy.exc import DBAPIError, IntegrityError
from sqlalchemy import func, or_
from .models import (
    DBSession,
    Post,
    User, 
    Article
    )

_ = TranslationStringFactory('lietlahti')

_re_login = re.compile(r'^[\w\d._-]+$')
article_status = {'draft':'Черновик', 'ready':'Готово', 'private':'Не трогать!'}

class Contacts():
	def __init__(self, conf):
		self.config = json.loads(conf)
		
	def get(self, cont_name):
		try:
			contact = self.config.get(cont_name, None)
			if contact is not None:
				return contact
		except:
			pass

@view_config(route_name='language')
def language(req):
	lang = req.params.get('lang', 'ru')
	retpath = req.params.get('ret', '/')
	req.session['lang'] = lang

	return HTTPSeeOther(location=req.host_url + retpath)

@view_config(route_name='main', renderer='template_main.mak')
def main_view(request):
	sess = DBSession()
	loc = get_localizer(request)
	locale_name = get_locale_name(request)
	cfg = request.registry.settings
	lang = request.session.get('lang', 'ru')
	contacts = Contacts(cfg.get('lietlahti.contacts', None))
	articles = DBSession.query(Article).order_by(Article.pubtimestamp.desc())
	tpldef = {'articles':articles, 'statuses':article_status, 'pagename':request.translate(_('Главная')), 'contacts': contacts, 'lang':lang, "_":request.translate }
	if authenticated_userid(request):
		user = sess.query(User).filter(User.name == authenticated_userid(request)).first()
		tpldef.update({
				'auth':True,
				'authuser':authenticated_userid(request),
				'user':user
				})
	return tpldef

@view_config(route_name='article', renderer='template_article.mak')
def article_view(request):
	sess = DBSession()
	loc = get_localizer(request)
	cfg = request.registry.settings
	lang = request.session.get('lang', 'ru')
	contacts = Contacts(cfg.get('lietlahti.contacts', None))
	recaptcha_key = cfg.get('recaptcha.public', False)
	header = DBSession.query(Article).filter(Article.series=='mainpage').order_by(Article.pubtimestamp.desc())
	article_url = request.matchdict.get('url', None)
	article = DBSession.query(Article).filter(Article.url==article_url).first()
	comments = DBSession.query(Post).filter(Post.page==article_url)
	pagename = article.getvalue("mainname", lang)

	tpldef = {'article':article, 'pagename':pagename, 'comments':comments, 'captchakey':recaptcha_key, 'articles':header, 'contacts':contacts, 'lang':lang, "_":request.translate}
	if authenticated_userid(request):
		user = sess.query(User).filter(User.name == authenticated_userid(request)).first()
		tpldef.update({
				'auth':True, 
				'authuser':authenticated_userid(request),
				'user':user
				})
	return tpldef

@view_config(route_name='newarticle', renderer='template_newarticle.mak')
def add_article(request):
	alllang = ['ru', 'en']
	loc = get_localizer(request)
	lang = request.session.get('lang', 'ru')

	if not authenticated_userid(request):
		# add error message processing in the template
		request.session.flash({
				'class' : 'warning',
				'text'  : request.translate(_('Войдите чтобы увидеть эту страницу'))
				})
		return HTTPSeeOther(location=request.route_url('login'))
	
	if not request.POST:
		user = DBsession.query(User).filter(User.name == authenticated_userid(request)).first()
		cfg = request.registry.settings
		contacts = Contacts(cfg.get('lietlahti.contacts', None))
		tpldef = {'alllang':alllang}
		header = DBSession.query(Article).filter(Article.series=='mainpage').order_by(Article.pubtimestamp.desc())
		article_series = set([s.series for s in DBSession.query(Article).all()])
		tpldef.update({
				'authuser':authenticated_userid(request), 
				'auth':True, 
				'article_status':article_status, 
				'article_series':article_series, 
				'pagename':'<span class="glyphicon glyphicon-pencil"></span>', 
				'articles':header, 
				'contacts':contacts, 
				'lang':lang, 
				"_":request.translate,
				'user':user})
		return tpldef
	else:
		user = DBsession.query(User).filter(User.name == authenticated_userid(request)).first()
		if user is None:
			pass
		csrf = request.POST.get('csrf', '')
		if csrf == request.session.get_csrf_token():
			art_name_ru = request.POST.get('inputMainname_ru', None)
			art_name_en = request.POST.get('inputMainname_en', None)
			art_text_ru = request.POST.get('inputArticle_ru', None)
			art_text_en = request.POST.get('inputArticle_en', None)
			art_prevtext_ru = request.POST.get('inputPrevText_ru', None)
			art_prevtext_en = request.POST.get('inputPrevText_en', None)
			
			art_kwords = request.POST.get('inputKeywords', None)
			art_descr = request.POST.get('inputDescr', None)
			art_url = request.POST.get('inputURL', None)
			art_status = request.POST.get('inputStatus', None)
			art_series = request.POST.get('inputSeries', None)
			art_leftbr = request.POST.get('inputLeftBracket', None)
			art_rightbr = request.POST.get('inputRightBracket', None)
			art_sep = request.POST.get('inputSep', None)

			art_prevpict = request.POST.get('inputPrevPict', None)
			newarticle = Article(
				art_kwords, 
				art_url, 
				art_descr, 
				datetime.datetime.now(), 
				authenticated_userid(request), 
				art_sep, 
				art_rightbr, 
				art_leftbr, 
				art_prevpict, 
				art_series, 
				art_status,
				mainname_ru=art_name_ru,
				previewtext_ru = art_prevtext_ru,
				maintext_ru = art_text_ru,
				mainname_en=art_name_en,
				previewtext_en = art_prevtext_en,
				maintext_en = art_text_en,
				)
			DBSession.add(newarticle)
			transaction.commit()
			# new article added here
		return HTTPSeeOther(location=request.route_url('main'))

@view_config(route_name='upload', renderer='json')
def upload_files(request):
	#print(" ".join([k for k in request.POST.values()]))
	#if 'file_input' in request.POST and hasattr(request.POST['file_input'], 'filename'):

	cfg = request.registry.settings
	temp_path = cfg.get('lietlahti.upload.temp', False)
	perm_path = cfg.get('lietlahti.upload.perm', False)
	filename = request.POST.get('0').filename
	fileext = os.path.splitext(filename)[-1]
	input_file = request.POST.get('0').file
	#we use datetime here beacuse of encoding problem, see issue 27
	savefilename = "{0}".format(datetime.datetime.now()).replace(" ", "_")+fileext
	keep = False
	if 'keep' in request.GET:
		upload_path = perm_path
		keep = True
	else:
		upload_path = temp_path

	file_path = os.path.join(upload_path, "{0}".format(savefilename))
	#file_path = file_path.encode('ascii', 'ignore')
	temp_file_path = file_path + '~'#.encode('utf-8')
	output_file = open(temp_file_path, 'wb')
	input_file.seek(0)
	while True:
		data = input_file.read(2<<16)
		if not data:
			break
		output_file.write(data)
	output_file.close()
	os.rename(temp_file_path, file_path)
	# Move filesharing host to the settings
	if keep == True:
		return "<a href='http://pomoyka.homelinux.net/immortal/{0}'>{0}</a>".format(savefilename)
	else:
		return "<a href='http://pomoyka.homelinux.net/files/{0}'>{1}</a>".format(savefilename, savefilename)


@view_config(route_name='newpost')
def add_new_post(request):
	succ = False
	sess = DBSession()
	cfg = request.registry.settings
	recaptcha_secret = cfg.get('recaptcha.secret', False)
	
	if not request.POST:
		return HTTPSeeOther(location=request.route_url('home'))
	else:
		csrf = request.POST.get('csrf', '')
		message = request.POST.get('userpost', None)
		ppage = request.POST.get('ppage', None)
		aid = request.POST.get('aid', None)
		captcha = request.POST.get('g-recaptcha-response', None)
		if authenticated_userid(request):
			username = authenticated_userid(request)
			if message and csrf == request.session.get_csrf_token() and ppage:
				newpost = Post(date = datetime.datetime.now(), page=ppage, name=username, ip=request.remote_addr, post=message, articleid=aid )
				DBSession.add(newpost)
				transaction.commit()
		

		else:
			username = request.POST.get('username', None)
			resp = urlopen("https://www.google.com/recaptcha/api/siteverify?secret={0}&response={1}".format(recaptcha_secret, captcha))
			
			captcharesp = json.loads(resp.read().decode("utf-8"))
			if captcharesp.get('success') is True:
				if message and csrf == request.session.get_csrf_token() and ppage:
					newpost = Post(date = datetime.datetime.now(), page=ppage, name=username, ip=request.remote_addr, post=message, articleid=aid )
					DBSession.add(newpost)
					transaction.commit()
					
		return HTTPSeeOther(location=request.referrer)

@view_config(route_name='home', renderer='template_discuss.mak')
@view_config(route_name='home_slash', renderer='template_discuss.mak')
@view_config(route_name='home:page', renderer='template_discuss.mak')
def discuss_view(request):
	loc = get_localizer(request)
	lang = request.session.get('lang', 'ru')
	on_page = 10
	first = 0
	last = 10
	page = request.matchdict.get('page', None)
	cfg = request.registry.settings
	contacts = Contacts(cfg.get('lietlahti.contacts', None))
	sess = DBSession()
	if not authenticated_userid(request):
		request.session.flash({
				'class' : 'warning',
				'text'  : request.translate(_('Войдите чтобы увидеть эту страницу'))
				})
		return HTTPSeeOther(location=request.route_url('login'))

	else:
		user = sess.query(User).filter(User.name == authenticated_userid(request)).first()
		header = DBSession.query(Article).filter(Article.series=='mainpage').order_by(Article.pubtimestamp.desc())
		max_page = DBSession.query(func.count(Post.id))[-1][-1]//on_page
		if page and int(page) > 0:
			page = int(page) - 1
			first = on_page * page
			last = first + on_page
			if int(page) > max_page:
				return HTTPSeeOther(location=request.route_url('home:page',page=max_page))
		posts = DBSession.query(Post).filter(Post.page == 'discuss').order_by(Post.id.desc()).slice(first, last)
		current_time = datetime.datetime.now()
		week_ago = current_time - datetime.timedelta(weeks=1)

		newcomments = DBSession.query(Post).filter(Post.date > week_ago).filter(Post.page != 'discuss')
		tomorrow = datetime.date.today()+datetime.timedelta(days=1)
		users = DBSession.query(User).filter(func.DATE_FORMAT(User.bday, "%d_%m")==tomorrow.strftime("%d_%m")).all()
	

		tpldef = {'posts': posts,
				  'page': page,
				  'articles': header,
				  'max_page':max_page,
				  'authuser':authenticated_userid(request),
				  'auth':True,
				  'pagename':"""<span class="glyphicon glyphicon-comment"></span>""",#.join([x.name for x in users])),
				  'newcomments':newcomments,
				  'contacts':contacts,
				  'lang':lang,
				  "_":request.translate,
				  'user':user
				  }
		return tpldef

@view_config(route_name='login', renderer='login.mak')
def login_view(request):
	loc = get_localizer(request)
	lang = request.session.get('lang', 'ru')
	_ = request.translate
	login_providers = {'facebook':'http://facebook.com',
                       'google'  :'http://google.com',
                       'twitter' :'http://twitter.com'
                       }
	
	login = ''
	did_fail = False
	cfg = request.registry.settings
	contacts = Contacts(cfg.get('lietlahti.contacts', None))
	nxt = request.route_url('main')
	if authenticated_userid(request):
		return HTTPSeeOther(location=nxt)
	if 'submit' in request.POST:
		csrf = request.POST.get('csrf', '')
		login = request.POST.get('user', '')
		passwd = request.POST.get('pass', '')

		if (csrf == request.session.get_csrf_token()) and login:
			sess = DBSession()
			q = sess.query(User).filter(User.name == login)
			for user in q:
				if user.password == passwd:
					headers = remember(request, login)
					request.response.headerlist.extend(headers)
					return HTTPFound(request.route_url('main'), headers=headers)
		did_fail = True
	header = DBSession.query(Article).filter(Article.series=='mainpage').order_by(Article.pubtimestamp.desc())
	tpldef = {
		'login'       : login,
		'articles'    : header,
		'failed'      : did_fail,
		'pagename'    : request.translate(_('Вход')),
		'contacts'    : contacts,
		'lang'        : lang,
		'login_providers': login_providers,
		"_"           : request.translate
		}
	return tpldef

@view_config(route_name='edit', renderer='template_newarticle.mak')
def pub_edit(request):
	loc = get_localizer(request)
	alllang = ['ru', 'en']
	lang = request.session.get('lang', 'ru')
	tpldef = {'alllang':alllang, 'lang':lang }

	if not authenticated_userid(request):
		request.session.flash({
				'class' : 'warning',
				'text'  : request.translate(_('Нужно войти чтобы увидеть эту страницу'))
				})
		return HTTPSeeOther(location=request.route_url('login'))
	else:
		cfg = request.registry.settings
		contacts = Contacts(cfg.get('lietlahti.contacts', None))

		pubtype = request.matchdict['pub']
		pubid = request.matchdict['id']
		if request.POST:
			if pubtype == 'post':
				csrf = request.POST.get('csrf', '')
				if csrf == request.session.get_csrf_token():
					newpost = request.POST.get('newpost', '')
					post = DBSession.query(Post).filter(Post.id==pubid).first()
					if post.name == authenticated_userid(request):
						post.post = newpost
						DBSession.add(post)
						transaction.commit()
						return HTTPSeeOther(location=request.referrer)

			elif pubtype == 'article':
				csrf = request.POST.get('csrf', '')
				if csrf == request.session.get_csrf_token():
					## GET other article params here
					article = DBSession.query(Article).filter(Article.id==pubid).first()
					#correct localization
					#correct article fields
					
					inputdict = {}
					for k in request.POST.keys():
						if k.startswith("input"):
							inputdict[k] = request.POST.get(k, None)

					for lng in alllang:
						mainname = "{0}_{1}".format("mainname", lng)
						maintext = "{0}_{1}".format("maintext", lng)
						prevtext = "{0}_{1}".format("previewtext", lng)

						article.setvalue(mainname, inputdict["inputMainname_"+lng])
						article.setvalue(maintext, inputdict["inputArticle_"+lng])
						article.setvalue(prevtext, inputdict["inputPrevText_"+lng])


					art_kwords = inputdict['inputKeywords']
					art_status = inputdict['inputStatus']
					art_url = inputdict['inputURL']
					art_series = inputdict['inputSeries']

					#SET them to the aricle
					article.keywords = art_kwords
					article.url = art_url
					article.series = art_series
					article.status = art_status
					article.user = authenticated_userid(request)
					article.edittimestamp = datetime.datetime.now()
					DBSession.add(article)
					transaction.commit()
					request.session.flash('edited')
					return HTTPSeeOther(location=request.referrer)
		else:
			if pubtype == 'article':
				header = DBSession.query(Article).filter(Article.series=='mainpage').order_by(Article.pubtimestamp.desc())
				article = DBSession.query(Article).filter(Article.id==pubid).first()
				article_series = set([s.series for s in DBSession.query(Article).all()])
				articleparams = {
					'edit':True,
					'article': article,
					'articles': header,
					'article_status':article_status,
					'article_series':article_series,
					'authuser':authenticated_userid(request), 
					'auth':True,
					'pagename': "{0} {1}".format(request.translate(_('Правка')), article.getvalue("mainname", lang)),
					'session_message':request.session.pop_flash(), 
					'contacts':contacts,
					'lang':lang,
					"_":request.translate
					}
				tpldef.update(articleparams)

				return tpldef

		return HTTPSeeOther(location=request.route_url('main'))

@view_config(route_name='remove')
def pub_remove(request):
	loc = get_localizer(request)
	if not authenticated_userid(request):
		request.session.flash({
				'class' : 'warning',
				'text'  : request.translate(_('Войдите чтобы увидеть эту страницу'))
				})
		return HTTPSeeOther(location=request.route_url('login'))
	else:
		pubtype = request.matchdict['pub']
		pubid = request.matchdict['id']
		if pubtype == 'post':
			post = DBSession.query(Post).filter(Post.id==pubid).first()
			if post.page == 'discuss':
				if post.name == authenticated_userid(request):
					DBSession.delete(post)
					transaction.commit()
					return HTTPSeeOther(location=request.referrer)
			else:
				DBSession.delete(post)
				transaction.commit()
				return HTTPSeeOther(location=request.referrer)
		elif pubtype == 'article':
			article = DBSession.query(Article).filter(Article.id==pubid).first()
			#if article.user == authenticated_userid(request):
			DBSession.delete(article)
			transaction.commit()
				#session.flash article deleted
			return HTTPSeeOther(location=request.route_url('main'))

	return HTTPSeeOther(location=request.referrer)

@view_config(route_name='logout')
def logout_view(request):
    if authenticated_userid(request):
        headers = forget(request)
        return HTTPFound(request.route_url("login"), headers=headers)
    else:
        return HTTPFound(request.route_url("login"))


@view_config(route_name='oauthwrapper', request_method='GET')
def client_oauth_wrapper(request):
	auth_provider = request.GET.get('prov', None)
	redirect_uri = request.route_url('main')

	if auth_provider == 'facebook':
		redirect_uri = request.route_url('oauthfacebook')
	elif auth_provider == 'google':
		redirect_uri = request.route_url('oauthgoogle')
	elif auth_provider == 'twitter':
		csrf = request.GET.get('csrf', None)
	email = request.GET.get('twitterEmail', None)
	if email and csrf == request.session.get_csrf_token():
		return HTTPFound(location=request.route_url('oauthtwitter', email=email))

	return HTTPSeeOther(redirect_uri)

@view_config(route_name='oauthtwitter', request_method='GET')
def client_oauth_twitter(request):
	if authenticated_userid(request):
		return HTTPSeeOther(location=request.route_url('main'))

	cfg = request.registry.settings
	loc = get_localizer(request)
	req_session = request.session
	min_pwd_len = 8
	auth_provider = 'twitter'
	email =  request.matchdict['email']
	redirect_uri = request.route_url('oauthtwitter', email=email)

	reg_params = {
		'email':email,
		'username':None,
		'password':None,
		'givenname':None,
		'familyname':None,
		}

	TWITTER_APP_ID = cfg.get('TWITTER_APP_ID', False)
	TWITTER_APP_SECRET = cfg.get('TWITTER_APP_SECRET', False)

	twitter = OAuth1Service(
		consumer_key=TWITTER_APP_ID,
		consumer_secret=TWITTER_APP_SECRET,
		name='twitter',
		authorize_url='https://api.twitter.com/oauth/authorize',
		access_token_url='https://api.twitter.com/oauth/access_token',
		request_token_url='https://api.twitter.com/oauth/request_token',
		base_url='https://api.twitter.com/1.1/')

	if TWITTER_APP_ID and TWITTER_APP_SECRET:
		auth_token = request.GET.get('oauth_token', False)
		auth_verifier = request.GET.get('oauth_verifier', False)

		if not auth_token and not auth_verifier:
			params = {
				'oauth_callback': redirect_uri,
				}

			authorize_url = twitter.get_raw_request_token(params=params)
			data = parse_utf8_qsl(authorize_url.content)
			req_session['twitter_oauth'] = (data['oauth_token'], data['oauth_token_secret'])
			return HTTPSeeOther(twitter.get_authorize_url(data['oauth_token'], **params))
		else:
			request_token, request_token_secret = req_session.pop('twitter_oauth')
			creds = {
				'request_token': request_token,
				'request_token_secret': request_token_secret
				}
			params = {'oauth_verifier': auth_verifier}
			sess = twitter.get_auth_session(params=params, **creds)
			res_json = sess.get('account/verify_credentials.json',
							  params={'format':'json'}).json()

			reg_params['username'] = res_json['screen_name'].replace(' ','').lower()
			reg_params['givenname'] = res_json['name'].split()[0]
			reg_params['familyname'] = res_json['name'].split()[-1]
			passwordhash = hashlib.sha224((auth_provider + reg_params['email'] + reg_params['username'] + str(res_json['id'])).encode('utf8')).hexdigest()
			reg_params['password'] = passwordhash[::3][:8]
			headers = client_oauth_register(request, reg_params)
			
			if headers:
				return HTTPSeeOther(location=request.route_url('main'), headers=headers)

	return HTTPSeeOther(location=request.route_url('login'))

@view_config(route_name='oauthgoogle', request_method='GET')
def client_oauth_google(request):
	cfg = request.registry.settings
	loc = get_localizer(request)
	min_pwd_len = int(cfg.get('registration.min_password_length', 8))
	auth_provider = 'google'
	reg_params = {
		'email':None,
		'username':None,
		'password':None,
		'givenname':None,
		'familyname':None,
		}

	GOOGLE_APP_ID = cfg.get('GOOGLE_APP_ID', False)
	GOOGLE_APP_SECRET = cfg.get('GOOGLE_APP_SECRET', False)
	gauthcode = request.GET.get('code', False)
	redirect_uri = request.route_url('oauthgoogle')

	google = OAuth2Service(
		client_id=GOOGLE_APP_ID,
		client_secret=GOOGLE_APP_SECRET,
		name='google',
		authorize_url='https://accounts.google.com/o/oauth2/auth',
		access_token_url='https://accounts.google.com/o/oauth2/token',
		base_url='https://accounts.google.com/o/oauth2/auth',
		)

	if gauthcode is not False:
		gsession = google.get_auth_session(
			data={
				'code'         : gauthcode,
				'redirect_uri' : redirect_uri,
				'grant_type'   : 'authorization_code'
				},
			decoder=lambda b: json.loads(b.decode())
			)
		json_path = 'https://www.googleapis.com/oauth2/v1/userinfo'
		res_json = gsession.get(json_path).json()
		
		reg_params['email'] = res_json['email']
		reg_params['username'] = res_json['email'].split("@")[0]
		reg_params['givenname'] = res_json['given_name']
		reg_params['familyname'] = res_json['family_name']

		passwordhash = hashlib.sha224((auth_provider + reg_params['email'] + reg_params['username'] + res_json['id']).encode('utf8')).hexdigest()
		reg_params['password'] = passwordhash[::3][:8]
		headers = client_oauth_register(request, reg_params)

		if headers:
			return HTTPSeeOther(location=request.route_url('main'), headers=headers)
		else:
			return HTTPSeeOther(location=request.route_url('main'))

	if GOOGLE_APP_ID and GOOGLE_APP_SECRET:
		params = {
			'scope': 'email profile',
			'response_type': 'code',
			'redirect_uri': redirect_uri
			}
		authorize_url = google.get_authorize_url(**params)
		return HTTPSeeOther(authorize_url)

@view_config(route_name='oauthfacebook', request_method='GET')
def client_oauth_facebook(request):
	if authenticated_userid(request):
		return HTTPSeeOther(location=request.route_url('main'))

	cfg = request.registry.settings
	loc = get_localizer(request)
	min_pwd_len = int(cfg.get('registration.min_password_length', 8))
	auth_provider = 'facebook'
	reg_params = {
		'email':None,
		'username':None,
		'password':None,
		'givenname':None,
		'familyname':None,
		}

	FACEBOOK_APP_ID = cfg.get('FACEBOOK_APP_ID', False)
	FACEBOOK_APP_SECRET = cfg.get('FACEBOOK_APP_SECRET', False)

	facebook = OAuth2Service(
		client_id=FACEBOOK_APP_ID,
		client_secret=FACEBOOK_APP_SECRET,
		name='facebook',
		authorize_url='https://graph.facebook.com/oauth/authorize',
		access_token_url='https://graph.facebook.com/oauth/access_token',
		base_url='https://graph.facebook.com/')

	fbauthcode = request.GET.get('code', False)

	redirect_uri = request.route_url('oauthfacebook')
	if fbauthcode is not False:
		fbsession = facebook.get_auth_session(data={'code': fbauthcode,	'redirect_uri': redirect_uri})
		
		res_json = fbsession.get('me?fields=name,email,first_name,last_name').json()

		print(res_json)
			
		reg_params['email'] = res_json['email']
		reg_params['username'] = res_json['name'].replace(' ','').lower()
		reg_params['givenname'] = res_json['first_name']
		reg_params['familyname'] = res_json['last_name']
		passwordhash = hashlib.sha224((auth_provider + reg_params['email'] + reg_params['username'] + res_json['id']).encode('utf8')).hexdigest()
		reg_params['password'] = passwordhash[::3][:8]

		headers = client_oauth_register(request, reg_params)

		if headers:
			return HTTPSeeOther(location=request.route_url('main'), headers=headers)

	if FACEBOOK_APP_ID and FACEBOOK_APP_SECRET:
		params = {'scope': 'email',
				  'response_type': 'code',
				  'redirect_uri': redirect_uri}
		authorize_url = facebook.get_authorize_url(**params)
		return HTTPSeeOther(authorize_url)
		
@view_config(route_name='oauthreg')
def client_oauth_register(request, regdict):
	nxt = request.route_url('main')
	loc = get_localizer(request)
	headers = None
	cfg = request.registry.settings
	mailer = get_mailer(request)
	errors = {}
	sess = DBSession()

	login = regdict.get('username', None)
	passwd = regdict.get('password', None)
	email = regdict.get('email', None)
	name_family = regdict.get('familyname', '')
	name_given = regdict.get('givenname', '')


	if login is not None and passwd is not None:
		q = sess.query(User).filter(User.name == login)
		logincount = q.count()
		if logincount == 1:
			if q is not None:
				for user in q:
					if user.password == passwd and user.name == login:
						headers = remember(request, login)
						return headers
					else:
						request.session.flash({
								'class' : 'warning',
								'text'  : request.translate(_('Пользователь с таким именем уже есть. Мы не знаем что вам делать'))
								})
						return False
						
		else:
			if headers is None:
				try:
					usr = User(login, passwd)
					usr.email = email
					usr.admin = 0
					sess.add(usr)
					#email user credentials to a given email
					sess.flush()
					headers = remember(request, login)
					message = Message(subject=request.translate(_("Новая учетная запись на lietlahti-park.ru")),
									  sender="noreply@piggy.thruhere.net",
									  recipients=[email,],
									  body="{0}: login - {1}, password - {2}".format(request.translate(_("Добро пожаловать на наш сайт, надеемся, что вам тут понравится. Ваши учетные данные")), login, passwd))
					mailer.send(message)
					transaction.commit()
					return headers

				except IntegrityError:
					sess.rollback()
					request.session.flash({
							'class' : 'warning',
							'text'  : request.translate(_('Пользователь с таким именем уже есть. Мы работаем над этой проблемой :('))
							})
					return False

	else:
		return False


@view_config(route_name='passrestore', request_method='GET')
def passrestore(request):
	mailer = get_mailer(request)
	sess = DBSession()
	redirect_uri = request.route_url('login')
	csrf = request.GET.get('csrf', None)
	uname = request.GET.get('userName', None)

	if uname and csrf == request.session.get_csrf_token():
		user = sess.query(User).filter(or_(User.name == uname, User.email == uname)).first()
		if user is not None:
			login = user.name
			email = user.email
			passwd = user.password
			message = Message(subject=request.translate(_("Восстановление учетной запись на lietlahti-park.ru")),
							  sender="noreply@piggy.thruhere.net",
							  recipients=[email,],
							  body="{0}: login - {1}, password - {2}".format(request.translate(_("Ваши учетные данные на lietlahti-park.ru")), login, passwd))
			mailer.send(message)
			transaction.commit()
			request.session.flash({
					'class' : 'info',
					'text'  : request.translate(_('Логин и пароль высланы на соответствующую электронную почту'))
					})
			return HTTPSeeOther(location=request.route_url('login'))
		else:
			request.session.flash({
					'class' : 'warning',
					'text'  : request.translate(_('Пользователя с таким именем не существует'))
					})
			return HTTPSeeOther(location=request.route_url('login'))
	else:
		request.session.flash({
				'class' : 'warning',
				'text'  : request.translate(_('Что-то пошло не так. Вы ввели имя пользователя?'))
				})
		return HTTPSeeOther(location=request.route_url('login'))
