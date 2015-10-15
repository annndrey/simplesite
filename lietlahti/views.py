#!/usr/bin/env python
# -*- coding: utf-8

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

import os 
import uuid
import json
import codecs
import datetime, time
import sched
import re 
from threading import Timer
from urllib.request import urlopen
from pyramid.response import Response
from sqlalchemy.exc import DBAPIError
from sqlalchemy import func
from .models import (
    DBSession,
    Post,
    User, 
    Article
    )


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
	cfg = request.registry.settings
	lang = request.session.get('lang', 'ru')
	contacts = Contacts(cfg.get('lietlahti.contacts', None))
	articles = DBSession.query(Article).order_by(Article.pubtimestamp.desc())
	tpldef = {'articles':articles, 'statuses':article_status, 'pagename':'Главная', 'contacts': contacts, 'lang':lang }
	if authenticated_userid(request):
		tpldef.update({
				'auth':True,
				'authuser':authenticated_userid(request),
				})
	return tpldef

@view_config(route_name='article', renderer='template_article.mak')
def article_view(request):
	cfg = request.registry.settings
	lang = request.session.get('lang', 'ru')
	contacts = Contacts(cfg.get('lietlahti.contacts', None))
	recaptcha_key = cfg.get('recaptcha.public', False)
	header = DBSession.query(Article).filter(Article.series=='mainpage').order_by(Article.pubtimestamp.desc())
	article_url = request.matchdict.get('url', None)
	article = DBSession.query(Article).filter(Article.url==article_url).first()
	comments = DBSession.query(Post).filter(Post.page==article_url)
	pagename = article.getvalue("mainname", lang)

	tpldef = {'article':article, 'pagename':pagename, 'comments':comments, 'captchakey':recaptcha_key, 'articles':header, 'contacts':contacts, 'lang':lang}
	if authenticated_userid(request):
		tpldef.update({'auth':True, 'authuser':authenticated_userid(request)})
	return tpldef

@view_config(route_name='newarticle', renderer='template_newarticle.mak')
def add_article(request):
	if not authenticated_userid(request):
		# add error message processing in the template
		request.session.flash({
				'class' : 'warning',
				'text'  : 'Войдите чтобы увидеть эту страницу'
				})
		return HTTPSeeOther(location=request.route_url('login'))
	if not request.POST:
		cfg = request.registry.settings
		contacts = Contacts(cfg.get('lietlahti.contacts', None))
		lang = request.session.get('lang', 'ru')
		tpldef = {}
		header = DBSession.query(Article).filter(Article.series=='mainpage').order_by(Article.pubtimestamp.desc())
		article_series = set([s.series for s in DBSession.query(Article).all()])
		tpldef.update({'authuser':authenticated_userid(request), 'auth':True, 'article_status':article_status, 'article_series':article_series, 'pagename':'<span class="glyphicon glyphicon-pencil"></span>', 'articles':header, 'contacts':contacts, 'lang':lang})
		return tpldef
	else:
		csrf = request.POST.get('csrf', '')
		if csrf == request.session.get_csrf_token():
			#correct localization!!!1
			#add language-specific fields, 
			#here we should have ALL languages at the same time
			art_name = request.POST.get('inputMainname_ru', None)
			art_uppername = art_name
			art_kwords = request.POST.get('inputKeywords', None)
			art_descr = request.POST.get('inputDescr', None)
			art_text = request.POST.get('inputArticle_ru', None)
			art_url = request.POST.get('inputURL', None)
			art_status = request.POST.get('inputStatus', None)
			art_series = request.POST.get('inputSeries', None)
			art_leftbr = request.POST.get('inputLeftBracket', None)
			art_rightbr = request.POST.get('inputRightBracket', None)
			art_sep = request.POST.get('inputSep', None)
			art_prevtext = request.POST.get('inputPrevText_ru', None)
			art_prevpict = request.POST.get('inputPrevPict', None)
			#correct article fields
			newarticle = Article(
				art_kwords, 
				art_url, 
				art_text, 
				art_descr, 
				datetime.datetime.now(), 
				authenticated_userid(request), 
				art_sep, 
				art_rightbr, 
				art_leftbr, 
				art_prevtext, 
				art_prevpict, 
				art_series, 
				art_status,
				mainname_ru=art_name)
			DBSession.add(newarticle)
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
		

		else:
			username = request.POST.get('username', None)
			resp = urlopen("https://www.google.com/recaptcha/api/siteverify?secret={0}&response={1}".format(recaptcha_secret, captcha))
			
			captcharesp = json.loads(resp.read().decode("utf-8"))
			if captcharesp.get('success') is True:
				if message and csrf == request.session.get_csrf_token() and ppage:
					newpost = Post(date = datetime.datetime.now(), page=ppage, name=username, ip=request.remote_addr, post=message, articleid=aid )
					DBSession.add(newpost)
					
		return HTTPSeeOther(location=request.referrer)

@view_config(route_name='home', renderer='template_discuss.mak')
@view_config(route_name='home_slash', renderer='template_discuss.mak')
@view_config(route_name='home:page', renderer='template_discuss.mak')
def discuss_view(request):
	lang = request.session.get('lang', 'ru')
	on_page = 10
	first = 0
	last = 10
	page = request.matchdict.get('page', None)
	cfg = request.registry.settings
	contacts = Contacts(cfg.get('lietlahti.contacts', None))

	if not authenticated_userid(request):
		request.session.flash({
				'class' : 'warning',
				'text'  : 'Войдите чтобы увидеть эту страницу'
				})
		return HTTPSeeOther(location=request.route_url('login'))

	else:
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
				  'lang':lang
				  }
		return tpldef

@view_config(route_name='login', renderer='login.mak')
def login_view(request):
	login = ''
	did_fail = False
	cfg = request.registry.settings
	contacts = Contacts(cfg.get('lietlahti.contacts', None))
	lang = request.session.get('lang', 'ru')
	nxt = request.route_url('home')
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
					return HTTPFound(request.route_url('home'), headers=headers)
		did_fail = True
	header = DBSession.query(Article).filter(Article.series=='mainpage').order_by(Article.pubtimestamp.desc())
	tpldef = {
		'login'       : login,
		'articles'    : header,
		'failed'      : did_fail,
		'pagename'    : 'Вход',
		'contacts'    : contacts,
		'lang'        : lang
		
		}
	return tpldef

@view_config(route_name='edit', renderer='template_newarticle.mak')
def pub_edit(request):
	alllang = ['ru', 'en']
	tpldef = {'alllang':alllang,}
	if not authenticated_userid(request):
		request.session.flash({
				'class' : 'warning',
				'text'  : 'You need to log in to access this page'
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
						prevtext = "{0}_{1}".format("prevtext", lng)

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
					request.session.flash('edited')
					return HTTPSeeOther(location=request.referrer)
		else:
			if pubtype == 'article':
				header = DBSession.query(Article).filter(Article.series=='mainpage').order_by(Article.pubtimestamp.desc())
				article = DBSession.query(Article).filter(Article.id==pubid).first()
				article_series = set([s.series for s in DBSession.query(Article).all()])
				lang = request.session.get('lang', 'ru')
				articleparams = {
					'edit':True,
					'article': article,
					'articles': header,
					'article_status':article_status,
					'article_series':article_series,
					'authuser':authenticated_userid(request), 
					'auth':True,
					'pagename': 'Правка %s' % article.getvalue("mainname", lang),
					'session_message':request.session.pop_flash(), 
					'contacts':contacts,
					'lang':lang
					}
				tpldef.update(articleparams)

				return tpldef

		return HTTPSeeOther(location=request.route_url('main'))

@view_config(route_name='remove')
def pub_remove(request):
	if not authenticated_userid(request):
		request.session.flash({
				'class' : 'warning',
				'text'  : 'Войдите чтобы увидеть эту страницу'
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
					return HTTPSeeOther(location=request.referrer)
			else:
				DBSession.delete(post)
				return HTTPSeeOther(location=request.referrer)
		elif pubtype == 'article':
			article = DBSession.query(Article).filter(Article.id==pubid).first()
			#if article.user == authenticated_userid(request):
			DBSession.delete(article)
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

