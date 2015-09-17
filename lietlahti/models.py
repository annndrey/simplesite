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
	mainname = Column(Unicode, unique=True)
	upname = Column(Unicode, unique=True)
	keywords = Column(Unicode(length=600))
	url = Column(Unicode, unique=True)
	maintext = Column(LONGTEXT)
	descr = Column(Unicode(length=600))
	series = Column(Unicode(length=600))
	previewtext = Column(Text)
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

	def __init__(self, mainname, upname, keywords, url, maintext, descr, pubtimestamp, user, sep_url, right_bracket_url, left_bracket_url, previewtext, previewpict, series, status):
		self.mainname = mainname
		self.upname = upname
		self.keywords = keywords
		self.url = url
		self.maintext = maintext
		self.descr = descr
		self.user = user
		self.sep_url = sep_url
		self.left_bracket_url = left_bracket_url
		self.right_bracket_url = right_bracket_url
		self.previewtext = previewtext
		self.previewpict = previewpict
		self.series = series
		self.status = status

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

