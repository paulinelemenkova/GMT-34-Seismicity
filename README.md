# GMT Seismicity — Earthquake and Tectonic Mapping Scripts

A collection of GMT (Generic Mapping Tools) shell scripts for mapping regional seismicity over shaded-relief topographic and bathymetric basemaps. Earthquake epicentres are plotted from seismic catalogues and scaled and coloured by magnitude, together with the tectonic and geological context. The scripts have been used to generate map figures across the author's geophysical and geoscientific publications.

## What the scripts do

Each script builds a complete seismotectonic map, typically chaining:

- grid clipping and subsetting (grdcut) over a study-area bounding box
- colour palette generation (makecpt) for the relief and a discrete magnitude ramp (seis CPT)
- shaded relief and raster rendering (grdimage) with illumination
- contour / isoline overlays (grdcontour)
- coastlines, political borders, rivers (pscoast / coast)
- earthquake epicentres plotted and sized by magnitude and depth (psxy, -i column selection)
- tectonic plate boundaries, ridges, fracture zones and volcanoes (psxy)
- colour scale bars (psscale), grids, frames, scale bars (psbasemap)
- magnitude legend (pslegend), annotations and labels (pstext)
- export to raster (psconvert) at high resolution

## Data sources

- Relief / bathymetry grids: GEBCO (15 arc-second), SRTM, ETOPO1
- Earthquake catalogues: IRIS Seismic Event Database and NOAA/NGDC significant-earthquake data (.ngdc / .tsv files included per region)
- Tectonic and geological vectors: plate-boundary polygons, GSFML fracture zones and magnetic lineations, ridges, volcano locations

## File naming

Scripts follow GMT-34-XX-seis.sh, where XX is an ISO 3166-1 country code (e.g. EC = Ecuador, VE = Venezuela, ET = Ethiopia) or a region / feature tag (e.g. TrP = Peru–Chile Trench). Accompanying quakes_*.ngdc and IEB_export_*.tsv files hold the earthquake data for each area.

## Requirements

- GMT 6.x (Generic Mapping Tools): https://www.generic-mapping-tools.org
- A POSIX shell (bash/sh)
- The relevant relief grid(s) (GEBCO / SRTM / ETOPO1) available locally
- GDAL (optional) for grid statistics (gdalinfo)

## Usage

Place the required relief grid and the region earthquake file in the working directory, adjust the -R region and -J projection at the top of the chosen script, then run:

    bash GMT-34-EC-seis.sh

The script writes a PostScript file and converts it to a raster image (JPG/PNG) via psconvert.

## Author and citation

Polina Lemenkova
ORCID: https://orcid.org/0000-0002-5759-1089

These scripts accompany figures in the author's geophysical and cartographic papers; please cite the specific article a given map appears in. The full publication list is available via the ORCID record above.

## License

See the LICENSE file in this repository.
