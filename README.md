# ubuild - Radxa U-Boot Build Tool

[![Build](https://github.com/radxa-repo/ubuild/actions/workflows/build.yml/badge.svg)](https://github.com/radxa-repo/ubuild/actions/workflows/build.yml)

`rbuild` aims to provide a standardized way to build U-Boot for Radxa boards, so the resulting file can be easliy included in our image generation pipeline. We also consolidate various existing `boot.cmd` and `uEnv.txt` in one place, hoping to deliver uniformed experience to our end users.

## Usage

### Local 

Please run the following command to check all available options:
```
git clone --depth 1 https://github.com/radxa-repo/ubuild.git
ubuild/ubuild
```

You can then build the bootloader with supported options. The resulting deb package will be stored in your current directory.

### Running in GitHub Action

Please check out our [GitHub workflows](https://github.com/radxa-repo/ubuild/tree/main/.github/workflows).

## Documentation
Please visit [Radxa Documentation](https://radxa-doc.github.io/).