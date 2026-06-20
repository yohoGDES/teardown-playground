# refresh-docs

Re-scrape the Teardown modding documentation into docs/teardown-modding/.

## Usage

/refresh-docs

## Steps

1. Check that Python dependencies are installed:
   ```bash
   pip install -r scripts/requirements.txt
   ```
2. Run the scraper:
   ```bash
   python scripts/fetch_docs.py
   ```
3. Report how many files were saved and list any pages that failed.
4. Stage the updated docs and ask the user if they want to commit.
