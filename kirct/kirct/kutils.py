from pyk.kore.syntax import Pattern
from enum import Enum
# untils for kore


class CellType(Enum):
    NORMAL = 'normal'
    MAP = 'map'
    SET = 'set'
    LIST = 'list'


def k_symbol(s: str) -> str:
    return f"Lbl'-LT-'{s}'-GT-'"


def k_collection_symbol(s: str, t:str) -> str:
    parts = s.split("-")
    camel_case_str = ''.join(part.capitalize() for part in parts)
    return f"Lbl{camel_case_str}Cell{t}Item"


def get_cell(term: Pattern, cells: list[(str, CellType)]) -> Pattern:
    if len(cells) == 0:
        return term
    if len(cells) == 1:
        if cells[0][1] == CellType.NORMAL:
            return next((cell for cell in term.patterns
                         if cell.symbol == k_symbol(cells[0][0])), None)
        else:
            return next((cell for cell in term.patterns[0].pattern.patterns
                         if cell.symbol == k_symbol(cells[0][0])), None)
    else:
        return get_cell(get_cell(term, [cells[0]]), cells[1:])




