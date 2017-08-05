from bookie.i_data_manager import IDataManager


class MockDataManager(IDataManager):
    def get_all(self, model):
        pass

    def insert(self, model_inst):
        pass

    def update(self, model_inst, id_):
        pass

    def get(self, model, id_):
        pass

    def delete(self, model, id_):
        pass
