from crewai.tools import BaseTool
from typing import Type
from pydantic import BaseModel, Field
import sqlite3
import json


class SQLInput(BaseModel):
    """Input schema for SQL Executor Tool."""

    sql_query: str = Field(
        ..., description="SQL query returned by the Query Validator agent for execution"
    )


class SQLExecutor(BaseTool):
    name: str = "SQL Executor"
    description: str = (
        "Executes a validated SQL query on the local SQLite database and returns the result."
    )
    args_schema: Type[BaseModel] = SQLInput

    def _run(self, sql_query: str) -> str:
        try:
            conn = sqlite3.connect("my_database.db")
            conn.row_factory = sqlite3.Row  # to get column names
            cursor = conn.cursor()
            cursor.execute(sql_query)
            rows = cursor.fetchall()
            conn.close()

            # Convert rows to list of dictionaries
            results = [dict(row) for row in rows]
            return json.dumps(results, indent=2)

        except Exception as e:
            return f"Query execution failed: {str(e)}"
