#!/usr/bin/env python3
"""Patch the auto-generated android/app/build.gradle.kts to use the release
keystore from android/key.properties. Idempotent — safe to re-run."""
import re
import sys
from pathlib import Path

if len(sys.argv) != 2:
    sys.exit("usage: patch_gradle.py <path-to-build.gradle.kts>")

p = Path(sys.argv[1])
src = p.read_text()

if 'signingConfigs.getByName("release")' in src:
    print("already patched, skipping")
    sys.exit(0)

# 1. Imports at top.
imports = (
    'import java.util.Properties\n'
    'import java.io.FileInputStream\n'
)
if "import java.util.Properties" not in src:
    src = imports + src

# 2. keystoreProperties block before `android {`.
ks_block = (
    'val keystoreProperties = Properties()\n'
    'val keystorePropertiesFile = rootProject.file("key.properties")\n'
    'if (keystorePropertiesFile.exists()) {\n'
    '    keystoreProperties.load(FileInputStream(keystorePropertiesFile))\n'
    '}\n\n'
)
src = re.sub(r'\nandroid \{', '\n' + ks_block + 'android {', src, count=1)

# 3. signingConfigs { release { ... } } inside android {} (right after defaultConfig).
signing = (
    '\n    signingConfigs {\n'
    '        create("release") {\n'
    '            keyAlias = keystoreProperties["keyAlias"] as String?\n'
    '            keyPassword = keystoreProperties["keyPassword"] as String?\n'
    '            storeFile = keystoreProperties["storeFile"]?.let { file("${it}") }\n'
    '            storePassword = keystoreProperties["storePassword"] as String?\n'
    '        }\n'
    '    }\n'
)
# Insert before the buildTypes block.
src = re.sub(r'\n    buildTypes \{', signing + '\n    buildTypes {', src, count=1)

# 4. Replace the debug release config with our release config.
src = re.sub(
    r'signingConfig = signingConfigs\.getByName\("debug"\)',
    'signingConfig = signingConfigs.getByName("release")',
    src,
)

p.write_text(src)
print("patched")
