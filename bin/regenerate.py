"""Regenerate .out files from .lean files when the source is newer.

Handles two cases:
1. Standalone .lean files — run via `lake env lean` from the repo root.
2. Lake projects (directory contains a lakefile.lean) — cd into that directory
   and run via `lake env lean` with a relative path so intra-project imports
   (e.g. `import code`) resolve correctly.

In both modes, if a matching .sh script exists it is used instead of `lake env lean`.
"""

from pathlib import Path
import subprocess
import sys


def run_lean(lean: Path) -> str:
    """Run a .lean file (or its companion .sh) and return stdout+stderr."""
    sh = lean.with_suffix(".sh")
    if sh.exists():
        result = subprocess.run(
            ["bash", str(sh)],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        return result.stdout

    # Is this .lean file part of a Lake project?
    lakefile = lean.parent / "lakefile.lean"
    if lakefile.exists():
        rel = lean.relative_to(lean.parent)
        result = subprocess.run(
            ["lake", "env", "lean", str(rel)],
            cwd=lean.parent,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
    else:
        result = subprocess.run(
            ["lake", "env", "lean", str(lean)],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
    return result.stdout


def main(subdirs: list[str]) -> None:
    for subdir in subdirs:
        base = Path(subdir)
        for lean in sorted(base.rglob("*.lean")):
            # Skip build artefacts inside .lake directories
            if any(p == ".lake" for p in lean.parts):
                continue
            # Skip lake project config files (not runnable as standalone .lean)
            if lean.name == "lakefile.lean":
                continue
            # Skip exercise starter files
            if lean.name.startswith("ex_"):
                continue

            out = lean.with_suffix(".out")
            sh = lean.with_suffix(".sh")
            sources = [lean, sh] if sh.exists() else [lean]
            if out.exists() and all(
                s.stat().st_mtime <= out.stat().st_mtime for s in sources
            ):
                continue
            print(f"{out}")
            out.write_text(run_lean(lean))

    sys.exit(0)


if __name__ == "__main__":
    main(sys.argv[1:])
