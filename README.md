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
| Source | The course distributes the dataset as `Nashville Housing Data for Data Cleaning.xlsx` in [AlexTheAnalyst/PortfolioProjects](https://github.com/AlexTheAnalyst/PortfolioProjects). That this exact file was used here, and where the data originally comes from: **Source pending verification.** |
| Included in this repo | **No.** The data is not included. |

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
├── CleaningDataSQL.sql   # Cleaning script, in execution order
└── README.md
```

## Results

The repository contains only the script, with no saved output, row counts or before/after extracts. **No numerical results are claimed.** The result of running the script is a cleaned version of the input table with split address columns, standardised values and no duplicate sales.

## How to run

1. Download the course dataset (see *Dataset and source*).
2. In SSMS, import it with the SQL Server Import and Export Wizard as a table called `NatshvilleHousing`.
3. **Work on a copy.** The script runs `UPDATE`, `DELETE` and `DROP COLUMN` statements that change the table permanently.
4. Run `CleaningDataSQL.sql` one block at a time and check each `SELECT` before the `UPDATE` that follows it.

## Limitations

- The final `DROP COLUMN` statement lists `SaleDateConverted` and `ConvertedSaleDate`, but the script creates a column called `SaleDateCom`. On a fresh table the statement fails because those columns do not exist. Adjust the column list before running it. The original statement is kept as written.
- `UPDATE ... SET SaleDate = CONVERT(Date, SaleDate)` does not change the column's data type. This is why the script also adds a new date column.
- Deleting duplicates directly from the source table cannot be undone. A production workflow would write to a staging or clean table instead.
- The script was not packaged with data, so results cannot be reproduced from this repository alone.

## Next steps

- Correct the `DROP COLUMN` list in a separate, documented commit.
- Write the cleaned output to a new table or view instead of changing the raw table.
- Add data-quality checks (row counts and null counts before and after).

## Credits

- Course and original cleaning steps: [Alex The Analyst – PortfolioProjects](https://github.com/AlexTheAnalyst/PortfolioProjects).

## Contact

**Kevin Espinoza**, Civil Engineer transitioning into Data Analytics and Automation
GitHub: [@kevinEspinozaTech](https://github.com/kevinEspinozaTech) · Email: [k.espinozano@gmail.com](mailto:k.espinozano@gmail.com)
