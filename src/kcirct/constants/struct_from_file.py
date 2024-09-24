from typing import List, TypedDict


class State(TypedDict):
    name: str
    offset: int
    numBits: int  # noqa: N815
    type: str


class StatesJson(TypedDict):
    name: str
    numStateBytes: int  # noqa: N815
    states: list[State]  # noqa: TC101
