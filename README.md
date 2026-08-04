<a href="https://www.islas.org.mx"><img src="https://www.islas.org.mx/img/logo.svg" align="right" width="256" /></a>

# Clean camera data
[![codecov](https://codecov.io/gh/IslasGECI/clean_camera_data/graph/badge.svg?token=wyxnwZypMA)](https://codecov.io/gh/IslasGECI/clean_camera_data)
![example branch
parameter](https://github.com/IslasGECI//clean_camera_data/actions/workflows/actions.yml/badge.svg)
![licencia](https://img.shields.io/github/license/IslasGECI/clean_camera_data)
![languages](https://img.shields.io/github/languages/top/IslasGECI/clean_camera_data)
![commits](https://img.shields.io/github/commit-activity/y/IslasGECI/clean_camera_data)
![GitHub contributors](https://img.shields.io/github/contributors/IslasGECI/clean_camera_data)
![R-version](https://img.shields.io/github/r-package/v/IslasGECI/clean_camera_data)

R package to clean and summarize camera trap monitoring data. It joins the
camera field checks with the camera memory checks, normalizes Spanish dates to
ISO format, fills the missing weekly records, and produces a weekly summary of
the installed camera traps, sampling effort, captured photos, and detected
individuals.
## CLI functions

- `write_cameras_summary(options)` — main entry point. Reads the camera field
  check and camera memory check CSVs and writes a weekly summary of camera traps, effort, photos, and
  individuals to the output CSV.

