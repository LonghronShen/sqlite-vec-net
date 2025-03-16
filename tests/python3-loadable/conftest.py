import os
import pytest
import sqlite3

from os.path import abspath


@pytest.fixture()
def db():
    db = sqlite3.connect(":memory:")
    db.row_factory = sqlite3.Row
    # db.enable_load_extension(True)
    # ext_path = abspath("../../build/bin/libvec0ex.dll")
    # print(f"Loading extension from: {ext_path}")
    # assert os.path.exists(ext_path)
    # db.load_extension(ext_path)
    # db.enable_load_extension(False)

    r = db.execute("SELECT sqlite_version();")
    rows: list[sqlite3.Row] = r.fetchall()
    print(rows[0].__dict__)

    return db
