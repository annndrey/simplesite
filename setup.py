import os

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
README = open(os.path.join(here, 'README.txt')).read()
CHANGES = open(os.path.join(here, 'CHANGES.txt')).read()

requires = [
    'pyramid',
    'SQLAlchemy',
    'transaction',
    'pyramid_tm',
    'pyramid_debugtoolbar',
    'zope.sqlalchemy',
    'waitress',
	'Babel'
    ]

setup(name='lietlahti',
      version='0.0',
      description='lietlahti',
      long_description=README + '\n\n' + CHANGES,
      classifiers=[
        "Programming Language :: Python",
        "Framework :: Pyramid",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
        ],
      author='Andrew Gontchar',
      author_email='gontchar@gmail.com',
      url='https://github.com/annndrey/lietlahti',
      keywords='web wsgi bfg pylons pyramid',
      packages=find_packages(),
      include_package_data=True,
      zip_safe=False,
      test_suite='lietlahti',
      install_requires=requires,
      entry_points="""\
      [paste.app_factory]
      main = lietlahti:main
      """,
	  message_extractors={'.' : [
			('**.py', 'python', None),
			('**.pt', 'xml', None),
			('**.mak', 'mako', None)
			]},
      )
