from model import KimulatorModel
import io


class KimulatorVCD:
    __vcdFile: io.TextIOWrapper = None
    top: KimulatorModel = None
    trace_level: int = 0

    def __init__(self, top: KimulatorModel, trace_level: int):
        self.top = top
        self.trace_level = trace_level
        return

    def __del__(self):
        if self.__vcdFile:
            self.__vcdFile.close()
        return

    def trace(self, model: KimulatorModel, levels: int):
        self.top = model
        self.trace_level = levels
        return

    def open(self, filename: str):
        pass

    def dump(self, time: int):
        pass