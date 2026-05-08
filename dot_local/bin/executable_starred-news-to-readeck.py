#!/usr/bin/env python3
"""
nextcloud-news-to-readeck.py

Fetches starred articles from Nextcloud News (API v1.3),
pushes them to Readeck with configurable labels (e.g. "news" + current date),
and removes the star from successfully synced articles.

Usage:
    python nextcloud-news-to-readeck.py [--config config.toml] [--dry-run] [--verbose]

Requirements:
    pip install requests          # always needed
    pip install tomli             # only if Python < 3.11
"""

import argparse
import logging
import sys
from datetime import date
from pathlib import Path

import requests

# ---------------------------------------------------------------------------
# Config loading
# ---------------------------------------------------------------------------


def load_config(path: str) -> dict:
    config_path = Path(path).expanduser()
    if not config_path.exists():
        sys.exit(f"Config file not found: {config_path}")

    try:
        import tomllib  # stdlib in Python 3.11+
    except ImportError:
        try:
            import tomli as tomllib  # pip install tomli
        except ImportError:
            sys.exit(
                "TOML library not available. Either use Python 3.11+ or run:\n"
                "  pip install tomli"
            )

    with open(config_path, "rb") as f:
        return tomllib.load(f)


# ---------------------------------------------------------------------------
# Nextcloud News client
# ---------------------------------------------------------------------------


class NextcloudNewsClient:
    def __init__(self, base_url: str, username: str, password: str):
        self.base = base_url.rstrip("/") + "/index.php/apps/news/api/v1-3"
        self.session = requests.Session()
        self.session.auth = (username, password)
        self.session.headers.update({"Content-Type": "application/json"})

    def get_starred(self) -> list[dict]:
        """Return all starred items."""
        resp = self.session.get(
            f"{self.base}/items",
            params={"type": 2, "getRead": "true", "batchSize": -1},
            timeout=30,
        )
        resp.raise_for_status()
        return resp.json().get("items", [])

    def unstar(self, items: list[dict]) -> None:
        """Remove star via POST /items/unstar/multiple (v1.3 bulk endpoint).

        v1.3 uses the key "itemIds" (list of ints).
        v1.2 used "items" with feedId+guidHash objects — do not confuse the two.
        """
        if not items:
            return
        item_ids = [item["id"] for item in items]
        resp = self.session.post(
            f"{self.base}/items/unstar/multiple",
            json={"itemIds": item_ids},
            timeout=30,
        )
        resp.raise_for_status()


# ---------------------------------------------------------------------------
# Readeck client
# ---------------------------------------------------------------------------


class ReadeckClient:
    def __init__(self, base_url: str, token: str):
        self.base = base_url.rstrip("/")
        self.session = requests.Session()
        self.session.headers.update(
            {
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json",
            }
        )

    def create_bookmark(
        self, url: str, title: str, labels: list[str]
    ) -> requests.Response:
        """Push a bookmark to Readeck and return the raw response."""
        return self.session.post(
            f"{self.base}/api/bookmarks",
            json={"url": url, "title": title, "labels": labels},
            timeout=30,
        )


# ---------------------------------------------------------------------------
# Core sync logic
# ---------------------------------------------------------------------------


def build_labels(cfg_sync: dict) -> list[str]:
    labels = list(cfg_sync.get("extra_labels", ["news"]))
    if cfg_sync.get("add_date_label", True):
        labels.append(str(date.today()))
    return labels


def sync(config: dict, dry_run: bool, log: logging.Logger) -> None:
    nc = NextcloudNewsClient(
        base_url=config["nextcloud"]["url"],
        username=config["nextcloud"]["username"],
        password=config["nextcloud"]["password"],
    )
    rd = ReadeckClient(
        base_url=config["readeck"]["url"],
        token=config["readeck"]["token"],
    )

    labels = build_labels(config.get("sync", {}))
    log.info("Labels to apply: %s", labels)

    log.info("Fetching starred articles from Nextcloud News ...")
    starred = nc.get_starred()
    log.info("Found %d starred article(s)", len(starred))

    if not starred:
        log.info("Nothing to do.")
        return

    successfully_synced: list[dict] = []

    for item in starred:
        item_id = item.get("id")
        url = item.get("url") or item.get("guid", "")
        title = item.get("title", url)

        log.info("[%s] %s", item_id, title)
        log.debug("  url=%s", url)

        if not url:
            log.warning("  Skipping item %s -- no URL found", item_id)
            continue

        if dry_run:
            log.info("  [DRY-RUN] Would push to Readeck and unstar.")
            continue

        resp = rd.create_bookmark(url=url, title=title, labels=labels)

        if resp.status_code in (200, 201, 202):
            log.info("  + Pushed to Readeck (HTTP %d)", resp.status_code)
            successfully_synced.append(item)
        elif resp.status_code == 422:
            # 422 = bookmark already exists in Readeck; unstar anyway
            log.info("  + Already exists in Readeck (HTTP 422) -- will unstar anyway")
            successfully_synced.append(item)
        else:
            log.warning(
                "  x Readeck returned HTTP %d -- keeping star. Body: %s",
                resp.status_code,
                resp.text[:200],
            )

    if successfully_synced:
        log.info("Removing star from %d article(s) ...", len(successfully_synced))
        nc.unstar(successfully_synced)
        log.info(
            "Done -- %d article(s) synced and unstarred.", len(successfully_synced)
        )
    else:
        log.info("No articles were successfully pushed; nothing unstarred.")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Sync starred Nextcloud News articles to Readeck."
    )
    parser.add_argument(
        "--config",
        default="~/.config/stoeps/news-sync.toml",
        help="Path to TOML config file (default: ~/.config/stoeps/news-sync.toml)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="List articles but do NOT push to Readeck or unstar.",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Enable debug-level logging.",
    )
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s  %(levelname)-8s  %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    log = logging.getLogger("nc2readeck")

    config = load_config(args.config)
    sync(config, dry_run=args.dry_run, log=log)


if __name__ == "__main__":
    main()
