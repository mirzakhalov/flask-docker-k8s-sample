from app.service import services as ss

def test_noOp():
    expected = ''
    actual = ss.noop()

    assert actual == expected