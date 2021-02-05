#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Malawi)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

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
    FONT_ANNOT_PRIMARY=7p,0,dimgray \
    FONT_LABEL=7p,0,dimgray \
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R33/48/3/15 -Get_relief1.nc
gmt grdcut GEBCO_2019.nc -R33/48/3/15 -Get_relief.nc
gdalinfo -stats et_relief.nc
# Min=-3481.000 Max=4326.000

# Make color palette
# Make color palette
gmt makecpt -Cdem2.cpt -V -T36/2846 > pauline.cpt
#gmt makecpt -CgrayC.cpt -V -T-3481/4326 > myocean1.cpt
gmt makecpt -Cseis -T2.8/6.5/0.5 -Z > steps.cpt
# srtm
#  dem1, dem2, dem3

ps=Geol_MW.ps
# Make raster image
gmt grdimage mw_relief.nc -Cpauline.cpt -R32/36/-17.5/-9 -JM5.0i -I+a15+ne0.75 -Xc -P -K > $ps

# Add legend
gmt psscale -Dg32/-17.85+w12.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f100a500+l"Color scale 'dem2' by Dewez/Wessel [R=36/2846, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour mw_relief.nc -R -J -C1000 -Wthinner,gray12 -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thicker,khaki1 -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --MAP_TITLE_OFFSET=0.9c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=14p,25,black \
    -Bpxg2f1a1 -Bpyg2f1a1 -Bsxg2 -Bsyg1 \
    -B+t"Seismicity in Malawi: earthquakes 1972 to 2021" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx11.0c/-3.8c+c50+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-110p -O -K >> $ps

# Add earthquake points
# separator in numbers of table: dot (.), not comma ! (British style)
gmt psxy -R -J quakes_MW.ngdc -Wfaint -i4,3,6,6s0.1 -h3 -Scc -Csteps.cpt -O -K >> $ps

# Add geological lines and points
gmt psxy -R -J volcanoes.gmt -St0.4c -Gred -Wthinnest -O -K >> $ps

# fabric and magnetic lineation picks fracture zones
gmt psxy -R -J GSFML_SF_FZ_KM.gmt -Wthicker,goldenrod1 -O -K >> $ps
gmt psxy -R -J GSFML_SF_FZ_RM.gmt -Wthicker,pink -O -K >> $ps
#gmt psxy -R -J LIPS.2011.gmt -L -Gpink1@70 -Wthinnest,red -O -K >> $ps
gmt psxy -R -J ridge.gmt -Sf0.5c/0.15c+l+t -Wthick,red -Gyellow -O -K >> $ps
gmt psxy -R -J ridge.gmt -Sc0.05c -Gred -Wthickest,red -O -K >> $ps
# tectonic plates
gmt psxy -R -J TP_Arabian.txt -L -Wthicker,purple -O -K >> $ps
gmt psxy -R -J TP_African.txt -L -Wthickest,purple -O -K >> $ps

gmt pslegend -R -J -Dx2.5/-3.2+w12.0c+o-2.0/0.1c \
    -F+pthin+ithinner+gwhite \
    --FONT=8p,black -O -K << FIN >> $ps
H 10 Helvetica Seismicity: earthquakes magnitude (M) from 2.8 to 6.5.
N 5
S 0.3c c 0.3c red 0.01c 0.5c M (6.3-6.5)
S 0.3c c 0.3c tomato 0.01c 0.5c M (5.8-6.3)
S 0.3c c 0.3c orange 0.01c 0.5c M (5.3-5.8)
S 0.3c c 0.3c yellow 0.01c 0.5c M (4.8-5.3)
S 0.3c c 0.3c chartreuse1 0.01c 0.5c M (4.3-4.8)
S 0.3c c 0.3c chartreuse1 0.01c 0.5c M (3.8-4.3)
S 0.3c c 0.3c cyan3 0.01c 0.5c M (3.3-3.8)
S 0.3c c 0.3c blue 0.01c 0.5c M (2.8-3.3)
S 0.3c t 0.3c red 0.03c 0.5c Volcanoes
FIN

# Add GMT logo
gmt logo -Dx5.0/-4.4+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y21.5c -N -O \
    -F+f11p,25,black+jLB >> $ps << EOF
-1.0 10.3 DEM: SRTM/GEBCO, 15 arc sec grid. Earthquakes: IRIS Seismic Event Database
EOF

# Convert to image file using GhostScript
gmt psconvert Geol_MW.ps -A3.5c -E720 -Tj -Z
