from setuptools import setup


packages = ['bookie_server']
requires = [
    'Flask',
    'Flask-RESTful',
    'Flask-SQLAlchemy',
    'SQLAlchemy',
    'python-dateutil',
    'webargs',
]


setup(
    name='Bookie-Server',
    packages=packages,
    include_package_data=True,
    install_requires=requires
)
