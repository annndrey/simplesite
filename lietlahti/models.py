from sqlalchemy import (
    Column,
    Integer,
    Text,
    Unicode,
	Enum,
	ForeignKey
    )
from sqlalchemy.dialects.mysql import DATETIME, TIMESTAMP, LONGTEXT, DATE, NUMERIC

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.orm import (
    scoped_session,
    sessionmaker,
	relationship
    )

from zope.sqlalchemy import ZopeTransactionExtension

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()


class Post(Base):
	__tablename__ = 'book'
	id = Column(Integer, primary_key=True)
	articleid = Column(Integer, ForeignKey('articles.id'), default=0)
	date = Column(DATETIME)
	page = Column(Unicode)
	name = Column(Unicode)
	ip = Column(Unicode)
	post = Column(Text)

	def __init__(self, date, page, name, ip, post, articleid):
		self.name = name
		self.date = date
		self.ip = ip
		self.page = page
		self.post = post
		self.articleid = articleid

	def __str__(self):
		return self.post


class Article(Base):
	__tablename__ = 'articles'
	id = Column(Integer, primary_key=True)
	mainname_ru = Column(Unicode, unique=True)
	mainname_en = Column(Unicode, unique=True)
	upname = Column(Unicode, unique=True)
	keywords = Column(Unicode(length=600))
	url = Column(Unicode, unique=True)
	maintext_ru = Column(LONGTEXT)
	maintext_en = Column(LONGTEXT)
	descr = Column(Unicode(length=600))
	series = Column(Unicode(length=600))
	previewtext_ru = Column(Text)
	previewtext_en = Column(Text)
	previewpict = Column(Unicode(length=600))
	sep_url = Column(Unicode(length=200))
	lat = Column(NUMERIC)
	lon = Column(NUMERIC)
	left_bracket_url = Column(Unicode(length=200))
	right_bracket_url = Column(Unicode(length=200))
	pubtimestamp = Column(TIMESTAMP)
	edittimestamp = Column(TIMESTAMP)
	user = Column(Unicode)
	posts = relationship("Post", backref='article')
	status = Column(
		'status',
		Enum('draft', 'ready', 'private'),
		nullable=False,
		default='draft',
		)

	def __init__(self, upname, keywords, url, descr, pubtimestamp, user, sep_url, right_bracket_url, left_bracket_url, previewpict, series, status, mainname_ru=None, mainname_en=None, maintext_ru=None, maintext_en=None, previewtext_ru=None, previewtext_en=None):
		#localization
		if mainname_ru is not None:
			self.mainname_ru = mainname_ru
		if mainname_en is not None:
			self.mainname_en = mainname_en
		if maintext_ru is not None:
			self.maintext_ru = maintext_ru
		if maintext_en is not None:
			self.maintext_en = maintext_en
		if previewtext_ru is not None:
			self.previewtext_ru = previewtext_ru
		if previewtext_en is not None:
			self.previewtext_en = previewtext_en

		self.upname = upname
		self.keywords = keywords
		self.url = url
		self.descr = descr
		self.user = user
		self.sep_url = sep_url
		self.left_bracket_url = left_bracket_url
		self.right_bracket_url = right_bracket_url
		self.previewpict = previewpict
		self.series = series
		self.status = status

	def getvalue(self, colname, lang):
		localized = "{0}_{1}".format(colname, lang)
		if hasattr(self, localized):
			return getattr(self, localized)

	def setvalue(self, colname, value):
		if hasattr(self, colname):
			self.__setattr__(colname, value)

#TODO md5 hash in password fields instead of plain text
class User(Base):
	__tablename__ = 'users'
	id = Column(Integer, primary_key=True)
	name = Column(Unicode)
	password = Column(Unicode)
	email = Column(Unicode(150))
	bday = Column(DATE)

	def __init__(self, name, password):
		self.name = name
		self.password = password

