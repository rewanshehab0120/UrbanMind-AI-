"""One-command launcher for the UrbanMind AI B2B Spatial Intelligence SaaS Platform."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "src"))

import uvicorn
from urbanmind.web_app import create_app


def main() -> None:
    parser = argparse.ArgumentParser(description="Launch the UrbanMind AI Spatial Intelligence web server.")
    parser.add_argument("--host", default="127.0.0.1", help="Bind host (default: 127.0.0.1)")
    parser.add_argument("--port", type=int, default=8000, help="Bind port (default: 8000)")
    args = parser.parse_args()

    app = create_app()
    print(f"\n  UrbanMind AI Platform running at http://{args.host}:{args.port}\n")
    uvicorn.run(app, host=args.host, port=args.port, log_level="info")


if __name__ == "__main__":
    main()
