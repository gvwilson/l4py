"""Regenerate .out files from .lean files when the source is newer."""

from pathlib import Path
import subprocess
import sys

for subdir in sys.argv[1:]:
    for lean in sorted(Path(subdir).glob("*.lean")):
        out = lean.with_suffix(".out")
        if out.exists() and lean.stat().st_mtime <= out.stat().st_mtime:
            continue
        print(f"{out}")
        result = subprocess.run(
            ["lake", "env", "lean", str(lean)],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        out.write_text(result.stdout)

sys.exit(0)
