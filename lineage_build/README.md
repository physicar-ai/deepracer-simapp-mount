# Lineage Core Build

Script that produces the `lineage_core.so` binary with the salt embedded.

## Usage

```bash
LINEAGE_SALT=<64-char hex value> ./build.sh
```

## Files

- `lineage_core.pyx.template` - Cython source template (placeholder where the salt is injected)
- `setup.py` - Cython build configuration
- `build.sh` - Build script (salt injection + compilation + cleanup)

## Notes

- Pass the salt only via environment variable (never commit it to source).
- Intermediate files (`.pyx`, `.c`) are deleted automatically after the build.
- Only the resulting `.so` is copied into the `markov/` folder.
