#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Yemen)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/pn/tn/moon.png.index.html

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

exec bash

cd /Users/polinalemenkova/Downloads/

tr ',' '\t' < IEB_export.csv > IEB_export.tsv

# Extract a subset of ETOPO1m for the Iceland area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R276/292/-30/-6 -Gpct_relief1.nc
gmt grdcut GEBCO_2023.nc -R276/292/-30/-6 -Gpct_relief.nc
gmt grdinfo pct_relief.nc
# v_min: -8997 v_max: 6781 name

# Make color palettes
# for topography
#gmt makecpt -Ctopo.cpt -V -T-5358/3447 > myocean.cpt
#gmt makecpt -Ceurope_3.cpt -V -T-5358/3447 > myocean.cpt
gmt makecpt -Cgmt/gray -V -T-8997/6781 > myocean.cpt
# for earthquakes
#gmt makecpt -Cred,green,blue -T0,7,9,12 > quakes.cpt
#gmt makecpt -Cseis > quakes.cpt
#gmt makecpt -Cseis -T4/6/0.1 -Z > steps.cpt
gmt makecpt -Cseis -T4/6.0/0.1 -Z > steps.cpt

ps=Seis_PCT.ps
# Make raster image
gmt grdimage pct_relief1.nc -Cmyocean.cpt -R276/292/-30/-6 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps

# Add legend
gmt psscale -Dg40.5/10.0+w13.0c/0.15i+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_TITLE=6p,Helvetica,black \
	-Bg500f50a500+l"Color ramp: grey [R=-8997/6781, continuous, RGB, 46 segments]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour pct_relief1.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thicker,khaki1 -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wEsN \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_TITLE=13p,13,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    -Bpxg2f1a2 -Bpyg2f1a2 -Bsxg2 -Bsyg1 \
    -B+t"Seismic setting in Peru-Chile Trench" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_LABEL_OFFSET=0.1c \
    -Tdx15.0c/10.4c+w0.3i+f2+l+o0.15i \
    -Lx14.3c/-3.6c+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/-5p/-105p -O -K >> $ps

# Texts

# Add earthquake points
#gmt psxy -R -J quakes_PCT.csv -Wfaint -i4,3,6,6s0.1 -h3 -Scc -Csteps.cpt -O -K >> $ps
gmt psxy -R -J IEB_export.tsv -Wfaint -i4,3,6,6+s0.1 -h3 -Scc -Csteps.cpt -O -K >> $ps

# Add geological lines and points
gmt psxy -R -J volcanoes.gmt -St0.4c -Gred -Wthinnest -O -K >> $ps

# fabric and magnetic lineation picks fracture zones
gmt psxy -R -J GSFML_SF_FZ_KM.gmt -Wthicker,goldenrod1 -O -K >> $ps
gmt psxy -R -J GSFML_SF_FZ_RM.gmt -Wthicker,pink -O -K >> $ps
gmt psxy -R -J LIPS.2011.gmt -L -Gpink1@50 -Wthinnest,red -O -K >> $ps
#gmt psxy -R -J ophiolites.gmt -Sc0.15c -Gmagenta -Wthinnest -O -K >> $ps
gmt psxy -R -J ridge.gmt -Sf0.5c/0.15c+l+t -Wthin,red -Gyellow -O -K >> $ps
gmt psxy -R -J ridge.gmt -Sc0.05c -Gred -Wthickest,red -O -K >> $ps
# tectonic plates
#gmt psxy -R -J TP_Arabian.txt -L -Wthicker,purple -O -K >> $ps
#gmt psxy -R -J TP_African.txt -L -Wthickest,purple -O -K >> $ps
#
gmt psmeca -R CMT.txt -J -Sd0.4/2/u -Gred -L0.1p -O -K >> $ps
gmt psmeca -R CMT.txt -J -Sc0.1/2/u -Gred -L0.1p -Fa/5p/it \
    -Fepurple -Fgmagenta -Ft -W0.1p -Fz -Eyellow -O -K >> $ps
gmt psmeca CMT.txt -R -J -Sd0.5/2/u -Gred -L0.1p -Fa/5p/it \
    -Fepurple -Fgmagenta -Ft -F+f8p,Times-Roman,yellow+jLB \
    -W0.1p -Fz -Ewhite -O -K >> $ps

#Texts
#gmt pstext -R -J -N -O -K \
#-F+f12p,Helvetica,brown+jLB -Gwhite@60 >> $ps << EOF
#44.2 10.8 A F R I C A N   P L A T E
#EOF

# Add legend -3.0
gmt pslegend -R -J -Dx0.3/-2.0+w18.0c+o-1.5/0.1c \
    -F+pthin+ithinner+gwhite \
    --FONT=8p,black -O -K << FIN >> $ps
H 10 Helvetica Tectonic and geologic elements
N 4
S 0.3c t 0.2c red 0.03c 1.0c Volcanoes
S 0.3c - 0.8c - 0.7p,brown 1.0c Tectonic slab
S 0.3c c 0.15c magenta 0.01c 1.0c Ophiolites
S 0.3c r 0.5c pink1@50 0.01c 1.0c Large igneous province
S 0.3c f+l+t 0.7c yellow 0.01c 1.0c Trenches, faults
S 0.3c - 0.9c - 0.7p,goldenrod1 1.0c Fracture zones
S 0.3c - 0.9c - 1.0p,red 1.0c Tectonic plates
FIN

gmt pslegend -R -J -Dx0.3/-3.1+w18.0c+o-1.5/0.1c \
    -F+pthin+ithinner+gwhite \
    --FONT=8p,black -O -K << FIN >> $ps
H 10 Helvetica Earthquake magnitude (M) and seismicity
N 4
S 0.3c c 0.3c red 0.01c 0.5c Magnitude high (5.5-6.0)
S 0.3c c 0.3c orange 0.01c 0.5c Magnitude moderate (5.0-5.5)
S 0.3c c 0.3c yellow 0.01c 0.5c Magnitude intermediate (4.5-5.0)
S 0.3c c 0.3c green 0.01c 0.5c Magnitude lowest (4.0-4.5)
FIN

# Add GMT logo
gmt logo -Dx7.0/-4.5+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.0c -N -O \
    -F+f11p,13,black+jLB >> $ps << EOF
1.2 8.9 Digital relief model: GEBCO/SRTM 15 arc-second grid of Earth surface
EOF

# Convert to image file using GhostScript
gmt psconvert Seis_PCT.ps -A2.5c -E720 -Tj -Z
