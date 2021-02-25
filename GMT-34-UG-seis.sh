#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Uganda)
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
#gmt grdcut ETOPO1_Ice_g_gmt4.grd -R29/35/-1.5/4.3 -Gug_relief.nc
gmt grdcut GEBCO_2019.nc -R29/35/-1.5/4.3 -Gug_relief.nc
gdalinfo -stats ug_relief.nc
# Minimum=443.980, Maximum=4905.871, Mean=1121.985, StdDev=356.040

# Make color palette
#gmt makecpt -CgrayC.cpt -V -T444/4906 > pauline.cpt
#gmt makecpt -Ccw2-037.cpt -V -T444/4906 > pauline.cpt
#gmt makecpt -Ccw2-072.cpt -V -T444/4906 > pauline.cpt
gmt makecpt -CCeramic.cpt -V -T444/4906 > pauline.cpt
#gmt makecpt -Cexponential.cpt -V -T444/4906 > pauline.cpt
gmt makecpt -Cseis -T3.7/6.2/0.5 -Z > steps.cpt
# srtm dem1, dem2, dem3

ps=Seis_UG.ps
# Make raster image
gmt grdimage ug_relief.nc -Cpauline.cpt -R29/35/-1.5/4.3 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps

# Add legend
gmt psscale -Dg29.0/-2.0+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Colormap: 'Ceramic' scheme from metallic and plastic style gradients [R=443/5110, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour ug_relief.nc -R -J -C1000 -A1000+f7p,26,darkbrown -Wthinner,darkbrown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,olivedrab1 -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg1f0.5a1 -Bpyg1f0.5a0.5 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=16p,25,black \
    -B+t"Seismicity in Uganda according to IRIS (1973-2021)" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-3.7c+c50+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/-10p/-110p -O -K >> $ps

# Add earthquake points
# separator in numbers of table: dot (.), not comma ! (British style)
gmt psxy -R -J quakes_UG.ngdc -Wfaint -i4,3,6,6s0.1 -h3 -Scc -Csteps.cpt -O -K >> $ps

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
# Cities
gmt pstext -R -J -N -O -K \
-F+f11p,0,white+jLB >> $ps << EOF
32.65 0.18 Kampala
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
32.58 0.31 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
32.10 0.40 Nansana
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.52 0.36 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB+a-345 >> $ps << EOF
32.62 0.45 Kira
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.63 0.40 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
31.9 0.14 Ssabagabo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.56 0.24 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
30.70 -0.65 Mbarara
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.65 -0.61 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB+a-345 >> $ps << EOF
32.80 0.40 Mukono
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.75 0.36 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
33.20 0.43 Njeru
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
33.15 0.43 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
32.05 2.82 Gulu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.30 2.78 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
33.00 0.33 Lugazi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.94 0.37 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
31.80 -0.30 Masaka
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.74 -0.34 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
30.15 0.15 Kasese
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.08 0.19 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
31.40 1.48 Hoima
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.35 1.43 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
32.95 2.27 Lira
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.9 2.25 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
31.60 0.40 Mityana
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.04 0.40 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
31.45 0.60 Mubende
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.40 0.55 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
31.75 1.75 Masindi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.72 1.68 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,white+jLB >> $ps << EOF
34.0 1.15 Mbale
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
34.17 1.07 0.20c
EOF
#
# Hydrology
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,white+jLB >> $ps << EOF
32.8 -0.40 L a k e
32.8 -0.70 V i c t o r i a
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-315 >> $ps << EOF
30.53 1.15 L a k e  A l b e r t
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,26,blue2+jLB+a-310 >> $ps << EOF
29.47 -0.55 Lake Edward
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,26,blue2+jLB >> $ps << EOF
30.3 0.00 Lake George
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,26,blue2+jLB+a-8 >> $ps << EOF
32.7 1.45 Lake Kyoga
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,26,blue2+jLB+a-340 >> $ps << EOF
32.5 1.60 Lake Kwania
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-75 >> $ps << EOF
32.8 1.25 Victoria Nile
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,yellow+jLB+a-50 >> $ps << EOF
32.57 2.8 Acuwa
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,yellow+jLB+a-330 >> $ps << EOF
31.3 1.25 Kafu
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,yellow+jLB+a-75 >> $ps << EOF
32.3 0.9 Lugo
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,26,yellow+jLB+a-295 >> $ps << EOF
31.43 3.05 Albert Nile
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,yellow+jLB+a-280 >> $ps << EOF
34.15 3.15 Dopeh
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,yellow+jLB+a-330 >> $ps << EOF
34.1 2.45 Oker
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,yellow+jLB+a-350 >> $ps << EOF
30.65 0.25 Katonga
EOF

# Mts
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,black+jLB >> $ps << EOF
30.0 0.38 Rwenzori
30.0 0.25 Mts
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,black+jLB >> $ps << EOF
34.5 1.40 Mt
34.5 1.28 Elgon
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,white+jLB >> $ps << EOF
34.4 3.8 K E N Y A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,white+jLB >> $ps << EOF
34.2 0.1 K  E  N  Y  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,white+jLB >> $ps << EOF
29.3 2.3 D. R. C O N G O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,white+jLB >> $ps << EOF
30.6 -1.30 T A N Z A N I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,white+jLB >> $ps << EOF
30.1 -1.5 RWANDA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,white+jLB >> $ps << EOF
30.85 4.1 S O U T H   S U D A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,25,white+jLB >> $ps << EOF
32.35 2.02 U   G   A   N   D   A
EOF


gmt pslegend -R -J -Dx1.5/-3.1+w17.7c+o-2.0/0.1c \
    -F+pthin+ithinner+gwhite \
    --FONT=8p,black -O -K << FIN >> $ps
H 10 Helvetica Seismicity: earthquakes magnitude (M) from 3.7 to 6.2.
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
gmt logo -Dx7.0/-4.5+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y10.6c -N -O \
    -F+f11p,25,black+jLB >> $ps << EOF
0.7 9.0 DEM: SRTM/GEBCO, 15 arc sec grid. Earthquakes: IRIS Seismic Event Database
EOF

# Convert to image file using GhostScript
gmt psconvert Seis_UG.ps -A2.0c -E720 -Tj -Z
