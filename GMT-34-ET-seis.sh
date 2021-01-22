#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Jordan)
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
gmt makecpt -Cgray.cpt -V -T-3481/4326 > myocean.cpt
gmt makecpt -CgrayC.cpt -V -T-3481/4326 > myocean1.cpt
gmt makecpt -Cseis -T2/7/0.25 -Z > steps.cpt
# srtm
#  dem1, dem2, dem3

ps=Geol_ET.ps
# Make raster image
gmt grdimage et_relief.nc -Cmyocean.cpt -R33/48/3/15 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps

# Add legend
gmt psscale -Dg31.5/3+w13.3c/0.15i+v+o0.0/0i+ml+e -R -J -Cmyocean1.cpt \
	--FONT_LABEL=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
	-Bg500f50a500+l"Color palette scale: perceptually uniform 'gray' colormap by F. Crameri [C=RGB]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour et_relief1.nc -R -J -C1000 -Wthinner,gray12 -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thicker,khaki1 -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --MAP_TITLE_OFFSET=0.9c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=17p,25,black \
    -Bpxg2f1a1 -Bpyg2f1a1 -Bsxg2 -Bsyg1 \
    -B+t"Seismicity in Ethiopia: earthquake magnitudes (2007 to 2020)" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.4c+c50+w250k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-70p -O -K >> $ps

# Add earthquake points
# separator in numbers of table: dot (.), not comma ! (British style)
gmt psxy -R -J quakes_ET.ngdc -Wfaint -i4,3,6,6s0.1 -h3 -Scc -Csteps.cpt -O -K >> $ps

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

gmt pslegend -R -J -Dx2.5/-1.8+w15.0c+o-2.0/0.1c \
    -F+pthin+ithinner+gwhite \
    --FONT=8p,black -O -K << FIN >> $ps
H 10 Helvetica Seismicity: earthquakes magnitude (M) and depth.
N 5
#S 0.3c c 0.3c red 0.01c 0.5c M (6.5-7.0)
#S 0.3c c 0.3c tomato 0.01c 0.5c M (6.0-6.5)
S 0.3c c 0.3c orange 0.01c 0.5c M (6.0-7.0)
S 0.3c c 0.3c yellow 0.01c 0.5c M (5.0-6.0)
#S 0.3c c 0.3c chartreuse1 0.01c 0.5c M (4.5-5.0)
S 0.3c c 0.3c chartreuse1 0.01c 0.5c M (4.0-5.0)
S 0.3c c 0.3c cyan3 0.01c 0.5c M (3.0-4.0)
#S 0.3c c 0.3c blue 0.01c 0.5c M (3.0-3.5)
S 0.3c t 0.3c red 0.03c 0.5c Volcanoes
FIN

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y8.0c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
0.5 9.0 DEM: SRTM/GEBCO, 15 arc sec resolution grid. Earthquakes: IRIS Seismic Event Database
EOF

# Convert to image file using GhostScript
gmt psconvert Geol_ET.ps -A1.0c -E720 -Tj -Z
