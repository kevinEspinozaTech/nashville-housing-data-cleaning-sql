# Nashville Housing Data Cleaning with SQL Server

A step-by-step T-SQL script that cleans a real-estate sales table: it standardises dates, fills missing addresses, splits address fields, normalises categorical values, removes duplicates and drops unused columns.

> **Guided learning project.** This project follows the *Data Analyst Portfolio Project* series by
> [Alex The Analyst](https://github.com/AlexTheAnalyst/PortfolioProjects) ("Data Cleaning Portfolio Project Queries").
> I ran and adapted the script against my own imported table. The cleaning steps and their order come from the course.

## Context

Raw operational data is rarely ready for analysis. This project practises turning a messy housing-sales table into a consistent, analysis-ready table using only SQL.

## Objectives

1. Convert the sale date into a proper `date` value.
2. Fill missing property addresses using other records with the same parcel.
3. Split combined address strings into address, city and state columns.
4. Standardise the *Sold as Vacant* field (`Y`/`N` → `Yes`/`No`).
5. Identify and remove duplicate sales.
6. Drop columns that are no longer needed.

## Technologies

- Microsoft SQL Server (T-SQL)
- SQL Server Management Studio (SSMS)

## Dataset and source

| Item | Detail |
|---|---|
| Source | Course file [`Nashville Housing Data for Data Cleaning.xlsx`](https://github.com/AlexTheAnalyst/PortfolioProjects) from AlexTheAnalyst/PortfolioProjects: 56,477 rows, 19 columns. The results below were produced from this file (SHA-256 `168835b6…cf48fd8`). Where the data originally comes from before the course: **Source pending verification.** |
| Included in this repo | **No.** [`data-prep/`](data-prep/) contains the scripts that convert the Excel file, create the table and load it. |

### Expected schema

The script works on one table named `NatshvilleHousing`. The name is spelled exactly like this in the script, so create the table with that name or adjust the script.

| Column | Used for |
|---|---|
| `[UniqueID ]` (with a trailing space, as produced by the Excel import) | Row identity in self-joins and duplicate detection |
| `ParcelID` | Matching rows to fill missing addresses; duplicate key |
| `PropertyAddress` | Filling missing values; splitting into address and city |
| `OwnerAddress` | Splitting into address, city and state |
| `SaleDate` | Date standardisation; duplicate key |
| `SalePrice`, `LegalReference` | Duplicate key |
| `SoldAsVacant` | `Y`/`N` → `Yes`/`No` |
| `TaxDistrict` | Dropped at the end |

## Methodology and techniques

| Step | Technique | Snippet |
|---|---|---|
| Standardise date | `CONVERT(Date, ...)`, `ALTER TABLE ... ADD`, `UPDATE` | `SET SaleDateCom = CONVERT(Date, SaleDate)` |
| Fill missing addresses | **Self-`JOIN`** on `ParcelID` with a different `UniqueID`, `ISNULL` | `UPDATE a SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)` |
| Split property address | `SUBSTRING`, `CHARINDEX`, `LEN` | `SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)` |
| Split owner address | `PARSENAME` + `REPLACE` | `PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)` |
| Normalise categories | `CASE WHEN` | `CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' ...` |
| Remove duplicates | **CTE** + **window function** `ROW_NUMBER() OVER (PARTITION BY ...)` | see below |
| Drop unused columns | `ALTER TABLE ... DROP COLUMN` | |

Duplicate removal:

```sql
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) row_num
    FROM NatshvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1
```

## Repository structure

```
.
├── CleaningDataSQL.sql          # Cleaning script, runnable end to end
├── data-prep/
│   ├── prepare_nashville.py     # Excel → TSV (requires openpyxl)
│   ├── create_table.sql         # Creates the database and the table
│   ├── load_with_bcp.cmd        # Loads the table with bcp
│   └── quality_checks.sql       # Before/after data-quality checks
└── README.md
```

## Results

Measured with `data-prep/quality_checks.sql` before and after running `CleaningDataSQL.sql` on SQL Server 2025 (2026-10-02):

| Check | Before | After |
|---|---|---|
| Rows | 56,477 | **56,373** (104 duplicate sales removed) |
| Columns | 19 | 21 (address, city and state split out; unused columns dropped) |
| Missing property addresses | 29 | **0** (filled from other sales of the same parcel) |
| `SoldAsVacant` values | 4 (`No` 51,403 · `Yes` 4,623 · `N` 399 · `Y` 52) | **2** (`No` 51,704 · `Yes` 4,669) |
| Remaining duplicates by the same key | 103 before filling the addresses | **0** |

The script removes 104 rows, one more than the 103 duplicates counted at the start. Filling the missing addresses reveals one more duplicate, because the duplicate key includes `PropertyAddress`.

## How to run

1. Download the course Excel file into `data-prep/`.
2. Run `python data-prep/prepare_nashville.py`. It writes `nashville.tsv`.
3. Run `sqlcmd -S localhost -E -C -i data-prep/create_table.sql`, then `data-prep\load_with_bcp.cmd`.
4. Optional: run `data-prep/quality_checks.sql` to record the "before" state.
5. Run `sqlcmd -S localhost -E -C -d NashvillePortfolio -i CleaningDataSQL.sql`, then run the quality checks again.

**Work on a copy.** The script runs `UPDATE`, `DELETE` and `DROP COLUMN` statements that change the table permanently.

## Limitations

- `UPDATE ... SET SaleDate = CONVERT(Date, SaleDate)` does not change the column's data type. This is why the script also adds a new date column (`SaleDateCom`).
- `SUBSTRING(..., CHARINDEX(',', ...) + 1, ...)` keeps the space after the comma, so the split city values start with a space (for example `" GOODLETTSVILLE"`). `PARSENAME` has the same issue. `LTRIM`/`TRIM` would fix it.
- Deleting duplicates directly from the source table cannot be undone. A production workflow would write to a staging or clean table instead.

### Fixed issues

In October 2026 the script was corrected in a separate pull request. The original version is preserved in Git history.

- The final `DROP COLUMN` listed columns that are never created (`SaleDateConverted`, `ConvertedSaleDate`). It now drops only `OwnerAddress, TaxDistrict, PropertyAddress, SaleDate`.
- The three `WITH RowNumCTE` statements now start with `;WITH`. `GO` separators were added after each `ALTER TABLE ... ADD`, so the new columns exist before they are updated. Before this change, the file could not be executed as a whole.

## Next steps

- Trim the leading space in the split city and state columns.
- Write the cleaned output to a new table or view instead of changing the raw table.

## Credits

- Course and original cleaning steps: [Alex The Analyst – PortfolioProjects](https://github.com/AlexTheAnalyst/PortfolioProjects).

## Contact

**Kevin Espinoza**, Civil Engineer transitioning into Data Analytics and Automation
GitHub: [@kevinEspinozaTech](https://github.com/kevinEspinozaTech) · Email: [k.espinozano@gmail.com](mailto:k.espinozano@gmail.com)
