import os
import pytest
import sqlite3

from os.path import abspath


def get_dylib_suffix():
    if os.name == "nt":
        return ".dll"
    elif os.name == "posix":
        if os.uname().sysname == "Darwin":
            return ".dylib"
        else:
            return ".so"
    else:
        raise ValueError(f"Unsupported OS: {os.name}")


def get_built_file_path(lib_file_name: str):
    ext_suffix = get_dylib_suffix()
    return abspath(f"../../build/bin/{lib_file_name}{ext_suffix}")


@pytest.fixture()
def db():
    sqlite3.enable_callback_tracebacks(True)

    db = sqlite3.connect(":memory:")
    db.row_factory = sqlite3.Row

    db.enable_load_extension(True)

    ext_path = get_built_file_path("libvec0ex")
    print(f"Loading extension from: {ext_path}")
    assert os.path.exists(ext_path)

    db.load_extension(ext_path)

    db.enable_load_extension(False)

    r = db.execute("SELECT sqlite_version();")
    rows: list[sqlite3.Row] = r.fetchall()
    rows_as_dicts = [dict(row) for row in rows]
    print(rows_as_dicts)

    return db
