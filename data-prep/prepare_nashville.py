"""Convert the course Excel file into a tab-separated file for bcp.

Input : Nashville Housing Data for Data Cleaning.xlsx (same folder)
Output: nashville.tsv (no header, empty cell = NULL, dates as YYYY-MM-DD HH:MM:SS)
Requires: openpyxl
"""
import datetime
from pathlib import Path

import openpyxl

HERE = Path(__file__).parent
wb = openpyxl.load_workbook(HERE / "Nashville Housing Data for Data Cleaning.xlsx", read_only=True)
rows = wb.worksheets[0].iter_rows(values_only=True)
next(rows)  # header
count = 0
with open(HERE / "nashville.tsv", "w", encoding="utf-8", newline="") as out:
    for row in rows:
        cells = []
        for value in row:
            if value is None:
                cells.append("")
            elif isinstance(value, datetime.datetime):
                cells.append(value.strftime("%Y-%m-%d %H:%M:%S"))
            else:
                cells.append(str(value).replace("\t", " ").replace("\r", " ").replace("\n", " "))
        out.write("\t".join(cells) + "\n")
        count += 1
print(f"{count} rows written to nashville.tsv")
