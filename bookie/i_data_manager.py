import abc


class IDataManager(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def get(self, model, id_):
        pass

    @abc.abstractmethod
    def get_all(self, model):
        pass

    @abc.abstractmethod
    def insert(self, model_inst):
        pass

    @abc.abstractmethod
    def update(self, model_inst, id_):
        pass

    @abc.abstractmethod
    def delete(self, model, id_):
        pass
