#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Rwanda)
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
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R28.5/31/-3/-1 -Get_relief1.nc
gmt grdcut GEBCO_2019.nc -R28.5/31/-3/-1 -Grw_relief.nc
gdalinfo -stats rw_relief.nc
# Min=-3481.000 Max=4326.000

# Make color palette
# Make color palette
gmt makecpt -CgrayC.cpt -V -T806/4360 > pauline.cpt
#gmt makecpt -CgrayC.cpt -V -T-3481/4326 > myocean1.cpt
gmt makecpt -Cseis -T3.7/6.2/0.5 -Z > steps.cpt
# srtm
#  dem1, dem2, dem3

ps=Seis_RW.ps
# Make raster image
gmt grdimage rw_relief.nc -Cpauline.cpt -R28.5/31/-3/-1 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps

# Add legend
gmt psscale -Dg28.5/-3.2+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Color scale 'dem2' by Dewez/Wessel [R=36/2846, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour rw_relief.nc -R -J -C1000 -Wthinner,gray12 -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,olivedrab1 -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg1f0.5a0.25 -Bpyg1f0.5a0.25 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=0.9c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=14p,25,black \
    -B+t"Seismicity in Rwanda and Kiwu Lake: earthquakes 1977 to 2020" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx13.5c/-3.7c+c50+w50k+l"Mercator projection. Scale (km)"+f \
    -UBL/-10p/-110p -O -K >> $ps

# Add earthquake points
# separator in numbers of table: dot (.), not comma ! (British style)
gmt psxy -R -J quakes_RW.ngdc -Wfaint -i4,3,6,6s0.1 -h3 -Scc -Csteps.cpt -O -K >> $ps

# Add geological lines and points
gmt psxy -R -J volcanoes.gmt -St0.4c -Gred -Wthinnest -O -K >> $ps

# fabric and magnetic lineation picks fracture zones
gmt psxy -R -J GSFML_SF_FZ_KM.gmt -Wthicker,goldenrod1 -O -K >> $ps
gmt psxy -R -J GSFML_SF_FZ_RM.gmt -Wthicker,pink -O -K >> $ps
#gmt psxy -R -J LIPS.2011.gmt -L -Gpink1@70 -Wthinnest,red -O -K >> $ps
gmt psxy -R -J ridge.gmt -Sf0.5c/0.15c+l+t -Wthick,red -Gyellow -O -K >> $ps
gmt psxy -R -J ridge.gmt -Sc0.05c -Gred -Wthickest,red -O -K >> $ps
# tectonic plates
gmt psxy -R -J TP_African.txt -L -Wthickest,purple -O -K >> $ps

# Texts
# Lakes
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
29.15 -1.95 Lake
29.15 -2.05 Kivu
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
30.32 -2.32 Lake
30.32 -2.37 Rweru
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
30.75 -1.81 Lake
30.75 -1.86 Ihema
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
30.31 -2.05 Lake
30.31 -2.10 Mugesera
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
30.4 -1.85 Lake Muhazi
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
29.78 -1.45 Lake Burera
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
29.74 -1.51 Lake Ruhondo
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
30.0 -2.25 Lake
29.9 -2.3 Cyohoha South
EOF

# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.4 -1.1 U  G  A  N  D  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.4 -2.9 B U R U N D I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.55 -2.65 T A N Z A N I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
28.6 -1.8 C O N G O
28.6 -1.9 (D.R.C.)
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,black+jLB >> $ps << EOF
29.6 -2.2 R    W    A    N    D    A
EOF
# Cities
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.08 -1.90 Kigali
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
30.06 -1.94 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.00 -1.5 Byumba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.06 -1.57 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.70 -2.30 Nyanza
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.73 -2.35 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.44 -1.97 Rwamagana
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.43 -1.95 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.70 -2.04 Muhanga
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.75 -2.08 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.36 -2.03 Kibuye
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.35 -2.06 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.70 -2.55 Butare
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.75 -2.6 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
28.90 -2.46 Cyangugu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
28.89 -2.48 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.56 -2.10 Kibungo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.54 -2.15 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.33 -1.31 Nyagatare
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.32 -1.29 0.20c
EOF

gmt pslegend -R -J -Dx1.5/-3.1+w17.7c+o-2.0/0.1c \
    -F+pthin+ithinner+gwhite \
    --FONT=8p,black -O -K << FIN >> $ps
H 10 Helvetica Seismicity: earthquakes magnitude (M) from 2.8 to 6.5.
N 9
S 0.3c c 0.3c red 0.01c 0.5c M (6.0-6.2)
S 0.3c c 0.3c tomato 0.01c 0.5c M (5.6-6.0)
S 0.3c c 0.3c orange 0.01c 0.5c M (5.3-5.6)
S 0.3c c 0.3c yellow 0.01c 0.5c M (5.0-5.3)
S 0.3c c 0.3c chartreuse1 0.01c 0.5c M (4.6-5.0)
S 0.3c c 0.3c chartreuse1 0.01c 0.5c M (4.3-4.6)
S 0.3c c 0.3c cyan3 0.01c 0.5c M (4.0-4.3)
S 0.3c c 0.3c blue 0.01c 0.5c M (3.7-4.0)

S 0.3c t 0.3c red 0.03c 0.5c Volcanoes
FIN

# Add GMT logo
gmt logo -Dx6.5/-4.6+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y7.0c -N -O \
    -F+f11p,25,black+jLB >> $ps << EOF
1.0 10.3 DEM: SRTM/GEBCO, 15 arc sec grid. Earthquakes: IRIS Seismic Event Database
EOF

# Convert to image file using GhostScript
gmt psconvert Seis_RW.ps -A2.0c -E720 -Tj -Z
