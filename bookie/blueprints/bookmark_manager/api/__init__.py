from flask_restful import Api

from .resources.bookmark import Bookmark
from .resources.tag import Tag
from ..app import bookmark_manager_bp

api = Api(bookmark_manager_bp, '/api')
api.add_resource(Bookmark, '/bookmark', '/bookmark/')
api.add_resource(Tag, '/tag', '/tag/')
