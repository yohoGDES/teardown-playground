#!/usr/bin/env python3
"""
Downloads the Teardown modding documentation from teardowngame.com/modding/
and saves each page as Markdown in docs/teardown-modding/.

The docs are authored in Markdeep (https://casual-effects.com/markdeep/), which
means the raw HTTP response is already Markdown with a small <meta> header and a
trailing <script>/<style> block that renders it in a browser. So instead of
parsing HTML, we just fetch the raw text and strip those wrappers.

Usage:
    pip3 install -r scripts/requirements.txt
    python3 scripts/fetch_docs.py

Re-run any time you want to refresh the docs.
"""

from __future__ import annotations  # modern type-hint syntax on Python 3.8

import os
import re
import time
import html2text
import requests
from urllib.parse import urljoin, urlparse

BASE_URL = "https://teardowngame.com/modding/"
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "docs", "teardown-modding")

# Pages to always fetch, even if nothing links to them. The index only links out
# to YouTube, so the reference pages need to be seeded explicitly.
SEED_PAGES = [
    "index.html",
    "api.html",
    "voxscript.html",
]

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
}

# Matches links to other .html pages, in either Markdown [text](page.html) form
# or raw HTML href="page.html" form.
LINK_RE = re.compile(r'(?:\]\(|href=["\'])([^)"\']+?\.html)(?:[)"\'#?])')

# Converter for pages that are plain HTML rather than Markdeep (e.g. api.html).
HTML_CONVERTER = html2text.HTML2Text()
HTML_CONVERTER.ignore_images = True
HTML_CONVERTER.body_width = 0  # no hard line wrapping
HTML_CONVERTER.protect_links = True


def url_to_filename(url: str) -> str:
    path = urlparse(url).path.rstrip("/")
    name = os.path.basename(path) or "index"
    return os.path.splitext(name)[0] + ".md"


def fetch_page(url: str):
    try:
        resp = requests.get(url, headers=HEADERS, timeout=15)
        resp.raise_for_status()
        return resp
    except requests.HTTPError as e:
        print(f"  HTTP error {e.response.status_code} for {url}")
        return None
    except requests.RequestException as e:
        print(f"  Request failed for {url}: {e}")
        return None


def extract_links(text: str, base: str):
    """Return in-scope /modding/*.html links found in the raw page text."""
    links = []
    for match in LINK_RE.findall(text):
        full = urljoin(base, match)
        parsed = urlparse(full)
        if (
            parsed.netloc == "teardowngame.com"
            and parsed.path.startswith("/modding/")
            and parsed.path.endswith(".html")
        ):
            links.append(full.split("#")[0].split("?")[0])
    return list(dict.fromkeys(links))  # de-duplicate, preserve order


def is_markdeep(raw: str) -> bool:
    """Markdeep pages declare themselves in the leading <meta> tag."""
    head = raw[:500]
    return "markdeep" in head.lower() or 'emacsmode="-*- markdown' in head


def clean_markdeep(raw: str) -> str:
    """Strip the Markdeep <meta> header and trailing <script>/<style> renderer,
    leaving just the Markdown body."""
    text = raw

    # Drop the leading "<meta charset ...>" line if present.
    text = re.sub(r"^\s*<meta[^>]*>\s*", "", text, count=1)

    # Markdeep appends its renderer at the end. Cut from the first sign of it:
    # a fallback <style>, the "<!-- Markdeep:" comment, or the closing <script>.
    cut_markers = [
        re.search(r'<style class="fallback">', text),
        re.search(r"<!--\s*Markdeep", text, re.IGNORECASE),
        re.search(r"<script[^>]*markdeep", text, re.IGNORECASE),
    ]
    positions = [m.start() for m in cut_markers if m]
    if positions:
        text = text[: min(positions)]
    return text.strip()


def to_markdown(raw: str, url: str) -> str:
    """Convert a fetched page to Markdown. Markdeep pages are already Markdown
    (just strip wrappers); plain HTML pages are run through html2text."""
    if is_markdeep(raw):
        body = clean_markdeep(raw)
    else:
        body = HTML_CONVERTER.handle(raw).strip()
    header = f"<!-- source: {url} -->\n\n"
    return header + body + "\n"


def scrape():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    visited: set = set()
    queue: list = [urljoin(BASE_URL, p) for p in SEED_PAGES]

    print(f"Starting from {BASE_URL}")
    print(f"Output: {os.path.abspath(OUTPUT_DIR)}\n")

    saved = 0
    while queue:
        url = queue.pop(0)
        if url in visited:
            continue
        visited.add(url)

        print(f"Fetching: {url}")
        resp = fetch_page(url)
        if resp is None:
            continue

        raw = resp.text

        # Discover links to other modding pages.
        for link in extract_links(raw, url):
            if link not in visited and link not in queue:
                queue.append(link)

        md = to_markdown(raw, url)
        if len(md.strip().splitlines()) <= 1:  # only the source comment
            print("  (empty content, skipping)")
            continue

        filename = url_to_filename(url)
        out_path = os.path.join(OUTPUT_DIR, filename)
        with open(out_path, "w", encoding="utf-8") as f:
            f.write(md)
        print(f"  Saved -> docs/teardown-modding/{filename}")
        saved += 1

        time.sleep(0.5)  # be polite

    print(f"\nDone. {saved} page(s) saved, {len(visited)} URL(s) visited.")
    print(f"Files in: {os.path.abspath(OUTPUT_DIR)}")


if __name__ == "__main__":
    scrape()
