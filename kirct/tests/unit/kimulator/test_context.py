from kirct.kimulator.context import *
import os


def test_temp_dir() -> None:
    # Given
    context = KimulatorContext()
    temp_dir = context.history_dir
    # Then
    assert os.path.exists(temp_dir)
    # When
    del context
    # Then
    assert not os.path.exists(temp_dir)
