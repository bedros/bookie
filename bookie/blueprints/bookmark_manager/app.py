from flask import Blueprint


bookmark_manager_bp = Blueprint('bookmark_manager',
                                __name__,
                                template_folder='templates')
