import sqlite3
import pytest
import json

from sqlite3 import Connection
from collections import OrderedDict

print("Running with Sqlite3 version: " + str(sqlite3.sqlite_version_info))


@pytest.mark.skipif(
    sqlite3.sqlite_version_info[1] < 37,
    reason="pragma_table_list was added in SQLite 3.37",
)
def test_shadow(db: Connection, snapshot):
    db.execute(
        "create virtual table v using vec0(a float[1], partition text partition key, metadata text, +name text, chunk_size=8)"
    )
    assert exec(db, "select * from sqlite_master order by name") == snapshot()
    assert (
        exec(db, "select * from pragma_table_list where type = 'shadow'") == snapshot()
    )

    db.execute("drop table v;")
    assert (
        exec(db, "select * from pragma_table_list where type = 'shadow'") == snapshot()
    )


def test_info(db: Connection, snapshot):
    db.execute("create virtual table v using vec0(a float[1])")
    info = exec(db, "select key, typeof(value) from v_info order by 1")
    print(json.dumps(info))
    assert info == snapshot()


def exec(db: Connection, sql: str, parameters: list = []):
    try:
        rows: list[sqlite3.Row] = db.execute(sql, parameters).fetchall()
    except (sqlite3.OperationalError, sqlite3.DatabaseError) as e:
        return {
            "error": e.__class__.__name__,
            "message": str(e),
        }
    result = OrderedDict()
    result["sql"] = sql
    result["rows"] = [dict(row) for row in rows]
    return result


# def vec0_shadow_table_contents(db: Connection, v):
#     shadow_tables = [
#         row[0]
#         for row in db.execute(
#             "select name from sqlite_master where name like ? order by 1", [f"{v}_%"]
#         ).fetchall()
#     ]
#     o = {}
#     for shadow_table in shadow_tables:
#         o[shadow_table] = exec(db, f"select * from {shadow_table}")
#     return o
