from SingletonMeta import SingletonMeta

class WordCounter(metaclass=SingletonMeta):
    count = 0

    def __iadd__(self, x):
        self.count += x
        return self.count

    def __int__(self):
        return self.count