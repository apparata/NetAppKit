#!/bin/sh

#
# Build reference documentation
#

# Requires sourcekitten at https://github.com/jpsim/SourceKitten.git

# Change directory to where this script is located
cd "$(dirname ${BASH_SOURCE[0]})"

# SourceKitten needs .build/debug.yaml, so let's build the package.
rm -rf .build
swift build

# The output will go in refdocs/
# Make sure /refdocs is in .gitignore
rm -rf docs/NetAppKit
mkdir -p "docs/NetAppKit"

sourcekitten doc --spm-module NetAppKit > NetAppKitDocs.json

jazzy \
  --clean \
  --swift-version 5.1.0 \
  --sourcekitten-sourcefile NetAppKitDocs.json \
  --author Apparata \
  --author_url http://apparata.se \
  --github_url https://github.com/apparata/NetAppKite \
  --output "docs/NetAppKit" \
  --readme "README.md" \
  --theme fullwidth \
  --source-directory .

rm NetAppKitDocs.json

open "docs/NetAppKit/index.html"
