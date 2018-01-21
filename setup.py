from setuptools import setup


setup(
    name='bookie',
    packages=['bookie'],
    include_package_data=True,
    install_requires=[
        'click',
        'flask',
        'sqlalchemy',
        'werkzeug',
    ],
)
