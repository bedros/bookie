from flask import Blueprint


bookmark_manager = Blueprint('bookmark_manager', __name__,
                             template_folder='templates')
