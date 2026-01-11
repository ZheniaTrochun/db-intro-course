def pytest_addoption(parser):
    parser.addoption("--snapshot", action="store", default="base")


def pytest_generate_tests(metafunc):
    option_value = metafunc.config.option.snapshot
    if 'snapshot' in metafunc.fixturenames and option_value is not None:
        metafunc.parametrize("snapshot", [option_value])