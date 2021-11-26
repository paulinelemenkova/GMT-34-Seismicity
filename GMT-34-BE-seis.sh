#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Panama)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
#http://soliton.vm.bytemark.co.uk/pub/cpt-city/esri/hillshade/tn/purple_gray_dk.png.index.html

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
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R2.5/6.5/49.5/51.7 -Gbe_relief.nc
gmt grdcut GEBCO_2019.nc -R2.5/6.5/49.5/51.7 -Gbe_relief.nc
gdalinfo -stats be_relief.nc
# Min=-5401.590 Max=6232.578

# Make color palette # -Ic
#gmt makecpt -CgrayC.cpt -V -T-164/680 > pauline.cpt
#gmt makecpt -CCeramic -V -T-164/680 > pauline.cpt
#gmt makecpt -CGlass -V -T-164/680 > pauline.cpt
#gmt makecpt -Cpseudogrey -V -T-164/680 > pauline.cpt
#gmt makecpt -Cdiff -V -T-164/680 > pauline.cpt
#gmt makecpt -Ccw5-047.cpt -V -T-164/680 > pauline.cpt
#gmt makecpt -Cpurple_gray_dk.cpt -V -T-164/680 > pauline.cpt
#gmt makecpt -Cbone.cpt -V -T-164/680 > pauline.cpt
#gmt makecpt -Ccw6-001.cpt -V -T-164/680 > pauline.cpt
gmt makecpt -Cgauss.cpt -V -T-164/680 > pauline.cpt
#gmt makecpt -Cexponential.cpt -V -T-164/680 > pauline.cpt
gmt makecpt -Cseis -T1.0/5.5/0.5 -Z > steps.cpt
# srtm dem1, dem2, dem3

ps=Seis_BE.ps
# Make raster image
gmt grdimage be_relief.nc -Cpauline.cpt -R2.5/6.5/49.5/51.7 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps

# Add legend
gmt psscale -Dg2.5/49.26+w15.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg100f10a100+l"Colormap: 'bone' scheme of h5utils package by MIT's S.G. Johnson, continuous, RGB, 63 segments [R=-5401/6233, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour be_relief.nc -R -J -C1000 -A1000+f7p,26,lavender -Wthinner,lavender -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,olivedrab1 -Wthin,lightcyan2 -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg1f1a0.5 -Bpyg0.5f0.5a0.5 -Bsxg1 -Bsyg0.5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=14p,25,black \
    -B+t"Seismicity in Belgium according to IRIS Seismic Event Database" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx13.0c/-3.4c+c10+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Add earthquake points
# separator in numbers of table: dot (.), not comma ! (British style)
# gmt psxy -R -J quakes_BE.ngdc -Wfaint -i4,3,6,6s0.05 -h3 -Scc -Csteps.cpt -O -K >> $ps
gmt psxy -R -J quakes_BE.ngdc -Wfaint -i4,3,6,6s0.10 -h3 -Scc -Csteps.cpt -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f17p,25,white+jLB >> $ps << EOF
4.25 50.54 B E L G I U M
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gwhite@60 >> $ps << EOF
4.40 50.84 Brussels
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
4.35 50.84 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,0,black+jLB -Gwhite@50 >> $ps << EOF
4.4 50.75 Uccle
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
4.33 50.8 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,BROWN4+jLB >> $ps << EOF
2.85 50.19 F  R  A  N  C  E
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,BROWN4+jLB >> $ps << EOF
4.45 51.55 N E T H E R L A N D S
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,BROWN4+jLB+a-270 >> $ps << EOF
6.38 50.6 G E R M A N Y
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,0,BROWN4+jLB -Gwhite@60 >> $ps << EOF
5.83 49.73 LUXEMBOURG
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,2,navyblue+jLB >> $ps << EOF
2.6 51.5 NORTH SEA
EOF

gmt pslegend -R -J -Dx1.5/-3.5+w17.8c+o-2.0/0.1c \
    -F+pthin+ithinner+gwhite \
    --FONT=8p,black -O -K << FIN >> $ps
H 10 Helvetica Seismicity: earthquakes magnitude (M) from 2.1 to 7.6
N 9
S 0.3c c 0.3c red 0.01c 0.5c M (7.4-7.8)
S 0.3c c 0.3c tomato 0.01c 0.5c M (7.1-7.3)
S 0.3c c 0.3c orange 0.01c 0.5c M (6.4-7.0)
S 0.3c c 0.3c yellow 0.01c 0.5c M (5.7-6.3)
S 0.3c c 0.3c chartreuse1 0.01c 0.5c M (5.0-5.6)
S 0.3c c 0.3c chartreuse1 0.01c 0.5c M (4.3-4.9)
S 0.3c c 0.3c cyan3 0.01c 0.5c M (3.6-4.2)
S 0.3c c 0.3c blue 0.01c 0.5c M (2.9-3.5)

S 0.3c t 0.3c red 0.03c 0.5c Volcanoes
FIN

# Add GMT logo
gmt logo -Dx7.0/-4.7+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y9.0c -N -O \
    -F+f11p,25,black+jLB >> $ps << EOF
0.7 9.0 DEM: SRTM/GEBCO, 15 arc sec grid.
EOF

# Convert to image file using GhostScript
gmt psconvert Seis_BE.ps -A1.7c -E720 -Tj -Z
