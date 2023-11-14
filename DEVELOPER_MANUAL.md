## Setup development environment for VSCode

After run `poetry install` to obtain a virtual environment, you should type the following text in the terminal to start a new VSCode window with the virtual environment activated:

```bash
poetry shell
code .
```

## Repository Structure

## Example to add a new feature

1. add a new argparser in `kirct/src/__main__.py`'s `create_argument_parser()` with argument name like 'symbolic-run'.
2. add a corresponding function in `kirct/src/__main__.py` with function name like `exec_run_symbolic()`.
3. add a corresponding fucntion in `kirct/src/kirct.py` as the callee.

## Contributing
