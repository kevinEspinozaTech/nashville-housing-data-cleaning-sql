@echo off
rem Loads nashville.tsv (created by prepare_nashville.py) into SQL Server with Windows authentication.
cd /d "%~dp0"
bcp "NashvillePortfolio.dbo.NatshvilleHousing" in nashville.tsv -S localhost -T -u -c -C 65001 -t "\t" -r 0x0a
