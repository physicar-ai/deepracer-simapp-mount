#!/bin/bash
# Lineage Core build script
# Usage: LINEAGE_SALT=<64-char hex> ./build.sh

set -e

if [ -z "$LINEAGE_SALT" ]; then
    echo "Error: LINEAGE_SALT environment variable is not set"
    echo "Usage: LINEAGE_SALT=<64-char hex value> ./build.sh"
    exit 1
fi

if [ ${#LINEAGE_SALT} -ne 64 ]; then
    echo "Error: LINEAGE_SALT must be a 64-character hex value (current length: ${#LINEAGE_SALT})"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Inject salt into the template
sed "s/__SALT_PLACEHOLDER__/$LINEAGE_SALT/g" lineage_core.pyx.template > lineage_core.pyx

# Compile inside the Docker container
docker run --rm --entrypoint="" \
    -v "$SCRIPT_DIR:/build" \
    -w /build \
    physicar/deepracer-simapp:5.3.3-cpu \
    bash -c "pip install cython && python3 setup.py build_ext --inplace"

# Copy build artifacts
OUTPUT_DIR="../sagemaker_rl_agent/lib/python3.8/site-packages/markov"
cp lineage_core.cpython-38-x86_64-linux-gnu.so "$OUTPUT_DIR/"

# Remove intermediate files (those that contain the salt)
rm -f lineage_core.pyx lineage_core.c
rm -rf build/

echo "Build complete: $OUTPUT_DIR/lineage_core.cpython-38-x86_64-linux-gnu.so"
