from pathlib import Path

import pytest

import kcirct.__main__ as main_module
from kcirct.api import KCIRCT


def _kore_file(tmp_path: Path) -> Path:
    kore_file = tmp_path / 'state.kore'
    kore_file.write_text('kore')
    return kore_file


def _kcirct_without_definition(monkeypatch: pytest.MonkeyPatch, rendered: str) -> KCIRCT:
    kcirct = object.__new__(KCIRCT)
    monkeypatch.setattr(KCIRCT, 'read_kore', staticmethod(lambda _path: object()))
    monkeypatch.setattr(kcirct, 'pretty', lambda _pattern: rendered)
    return kcirct


def test_pretty_parser_defaults_output_to_none(tmp_path: Path) -> None:
    kore_file = _kore_file(tmp_path)

    args = main_module.create_arg_parser().parse_args(['pretty', str(kore_file)])

    assert args.command == 'pretty'
    assert args.input == kore_file
    assert args.output is None


@pytest.mark.parametrize('output_option', ['-o', '--output'])
def test_pretty_parser_accepts_output(tmp_path: Path, output_option: str) -> None:
    kore_file = _kore_file(tmp_path)
    pretty_file = tmp_path / 'debug.pretty'

    args = main_module.create_arg_parser().parse_args(['pretty', str(kore_file), output_option, str(pretty_file)])

    assert Path(args.output) == pretty_file


def test_exec_pretty_uses_default_output(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    kore_file = _kore_file(tmp_path)
    pretty_file = Path(f'{kore_file}.pretty')
    calls: list[tuple[Path, Path]] = []

    class FakeKCIRCT:
        def write_pretty(self, input_file: Path, output_file: Path) -> None:
            calls.append((input_file, output_file))

    monkeypatch.setattr(main_module, 'KCIRCT', FakeKCIRCT)

    main_module.exec_pretty(input=kore_file, output=None)

    assert calls == [(kore_file, pretty_file)]
    assert str(pretty_file) in capsys.readouterr().out


def test_exec_pretty_uses_explicit_output(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    kore_file = _kore_file(tmp_path)
    pretty_file = tmp_path / 'debug.pretty'
    calls: list[tuple[Path, Path]] = []

    class FakeKCIRCT:
        def write_pretty(self, input_file: Path, output_file: Path) -> None:
            calls.append((input_file, output_file))

    monkeypatch.setattr(main_module, 'KCIRCT', FakeKCIRCT)

    main_module.exec_pretty(input=kore_file, output=pretty_file)

    assert calls == [(kore_file, pretty_file)]
    assert str(pretty_file) in capsys.readouterr().out


def test_write_pretty_replaces_output_without_leaving_temporary_file(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    kore_file = _kore_file(tmp_path)
    pretty_file = tmp_path / 'state.kore.pretty'
    pretty_file.write_text('old output')
    kcirct = _kcirct_without_definition(monkeypatch, 'new output')

    kcirct.write_pretty(kore_file, pretty_file)

    assert pretty_file.read_text() == 'new output'
    assert list(tmp_path.glob(f'.{pretty_file.name}.*.tmp')) == []


def test_write_pretty_preserves_output_when_rendering_fails(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    kore_file = _kore_file(tmp_path)
    pretty_file = tmp_path / 'state.kore.pretty'
    pretty_file.write_text('old output')
    kcirct = _kcirct_without_definition(monkeypatch, 'unused')

    def raise_render_error(_pattern: object) -> str:
        raise RuntimeError('render failed')

    monkeypatch.setattr(kcirct, 'pretty', raise_render_error)

    with pytest.raises(RuntimeError, match='render failed'):
        kcirct.write_pretty(kore_file, pretty_file)

    assert pretty_file.read_text() == 'old output'
    assert list(tmp_path.glob(f'.{pretty_file.name}.*.tmp')) == []


def test_write_pretty_rejects_input_as_output(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    kore_file = _kore_file(tmp_path)
    kcirct = _kcirct_without_definition(monkeypatch, 'unused')

    with pytest.raises(ValueError, match='Output path must differ from input path'):
        kcirct.write_pretty(kore_file, kore_file)
