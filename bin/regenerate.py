"""Regenerate .out files from .lean files when the source is newer."""

from pathlib import Path
import subprocess
import sys

for subdir in sys.argv[1:]:
    for lean in sorted(Path(subdir).glob("*.lean")):
        out = lean.with_suffix(".out")
        sh = lean.with_suffix(".sh")
        sources = [lean, sh] if sh.exists() else [lean]
        if out.exists() and all(s.stat().st_mtime <= out.stat().st_mtime for s in sources):
            continue
        print(f"{out}")
        cmd = ["bash", str(sh)] if sh.exists() else ["lake", "env", "lean", str(lean)]
        result = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        out.write_text(result.stdout)

sys.exit(0)
