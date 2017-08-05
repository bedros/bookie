from bookie import util, factory
from bookie.data_manager import DataManager

################################################################################
VERSION = ('0.2.0-dev', 'reflexive rhea')
################################################################################


app = factory.create_app()
app.data_manager = DataManager(app.config['DATABASE_URI'])
