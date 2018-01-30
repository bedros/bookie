from setuptools import setup


setup(
    name='bookie',
    packages=['bookie'],
    include_package_data=True,
    install_requires=[
        'Flask-RESTful',
        'Flask-SQLAlchemy',
        'SQLAlchemy',
        'click',
        'python-dateutil'
        'pytz',
        'webargs',
        'werkzeug',
    ],
)
