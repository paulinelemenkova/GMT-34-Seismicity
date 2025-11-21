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

# Extract a subset of ETOPO1m for the Iceland area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R42/55/10/20 -Gye_relief1.nc
gmt grdcut GEBCO_2019.nc -R42/55/10/20 -Gye_relief.nc
gdalinfo -stats ye_relief.nc
# Minimum=-3549.000, Maximum=7966.000

# Make color palettes
# for topography
#gmt makecpt -Ctopo.cpt -V -T-5358/3447 > myocean.cpt
#gmt makecpt -Ceurope_3.cpt -V -T-5358/3447 > myocean.cpt
gmt makecpt -Cmoon.cpt -V -T-5358/3447 > myocean.cpt
# for earthquakes
#gmt makecpt -Cred,green,blue -T0,7,9,12 > quakes.cpt
#gmt makecpt -Cseis > quakes.cpt
gmt makecpt -Cseis -T4/6/0.1 -Z > steps.cpt

ps=Geol_YE.ps
# Make raster image
gmt grdimage ye_relief.nc -Cmyocean.cpt -R42/55/10/20 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps

# Add legend
gmt psscale -Dg40.5/10.0+w13.0c/0.15i+v+o0.3/0i+ml -R -J -Cmyocean.cpt \
	--FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_TITLE=6p,Helvetica,black \
	-Bg500f50a500+l"Color ramp: 'moon' by Paul Naylor for the Ordnance Survey, UK [R=-5358/3447, continuous, RGB, 46 segments]" \
	-I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour ye_relief1.nc -R -J -C1000 -W0.1p -O -K >> $ps

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
    -B+t"Seismic and tectonic setting in Yemen and Gulf of Aden" -O -K >> $ps
    
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
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,red+jLB+a-340 >> $ps << EOF
53.0 17.8 O    M    A    N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,red+jLB+a-340 >> $ps << EOF
46.1 17.8 S  A  U  D  I     A  R  A  B  I  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,red+jLB+a-330 -Gwhite@30 >> $ps << EOF
42.1 11.5 DJIBOUTI
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,red+jLB+a-350 >> $ps << EOF
47.0 10.3 S   O   M   A   L   I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f16p,25,darkbrown+jLB+a-340 >> $ps << EOF
46.3 15.9 Y        E        M        E        N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,red+jLB+a-50 -Gwhite@30 >> $ps << EOF
42.0 13.4 ERITREA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,25,red+jLB+a-60 -Gwhite@30 >> $ps << EOF
42.0 10.9 ETHIOPIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,13,blue+jLB+a-340 -Gwhite@50 >> $ps << EOF
46.5 11.7 G u l f   o f   A d e n
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,13,white+jLB >> $ps << EOF
53.4 15.8 Arabian
53.7 15.4 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,13,white+jLB >> $ps << EOF
53.7 10.8 Indian
53.6 10.4 Ocean
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-60 -Gwhite@70 >> $ps << EOF
42.9 13.4 Bab-el-Mandeb
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,chocolate4+jLB+a-340 >> $ps << EOF
46.1 18.7 A R   R U B'  A L  K H A L I
46.5 18.5 (Empty Quarter Desert)
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB+a-82 -Gwhite@70 >> $ps << EOF
42.2 16.5 R e d   S e a
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,brown4+jLB >> $ps << EOF
53.5 12.0 Socotra
EOF
gmt pstext -R -J -N -O -K \
-F+f13p,13,darkbrown+jLB+a-345 >> $ps << EOF
47.7 15.1 H A D H R A M A U T
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,darkbrown+jLB+a-18 >> $ps << EOF
51.0 17.1 Jabal Mahra
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,darkbrown+jLB >> $ps << EOF
50.1 16.8 Jabal Bin
50.1 16.5 Kushayt
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,darkbrown+jLB+a-45 >> $ps << EOF
44.6 17.3 Ramlat Dahm
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,darkbrown+jLB+a-330 >> $ps << EOF
46.4 15.3 Ramlat
46.4 15.0 al-Sab'atayn
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,darkbrown+jLB >> $ps << EOF
43.3 15.2 Jabal
43.3 14.9 Haraz
EOF
# cities
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@30 >> $ps << EOF
44.2 15.4 Sana'a
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
44.1 15.2 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
45.1 13.1 Aden
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
45.0 13.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
44.2 13.2 Taiz
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
44.0 13.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
43.1 14.6 Al Hudaydah
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
43.0 14.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
44.2 13.7 Ibb
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
44.1 13.6 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
49.1 14.4 Al Mukalla
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
49.0 14.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
44.3 14.4 Dhamar
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
44.2 14.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
43.3 15.6 Amran
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
43.6 15.4 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,13,black+jLB -Gwhite@30 >> $ps << EOF
43.5 16.7 Sadah
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
43.4 16.6 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,13,black+jLB -Gwhite@30 >> $ps << EOF
51.5 15.8 Al Ghaydah
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
52.1 16.1 0.20c
EOF

# Add earthquake points
gmt psxy -R -J quakes_Yemen.ngdc -Wfaint -i4,3,6,6s0.1 -h3 -Scc -Csteps.cpt -O -K >> $ps

# Add geological lines and points
gmt psxy -R -J volcanoes.gmt -St0.4c -Gred -Wthinnest -O -K >> $ps

# fabric and magnetic lineation picks fracture zones
gmt psxy -R -J GSFML_SF_FZ_KM.gmt -Wthicker,goldenrod1 -O -K >> $ps
gmt psxy -R -J GSFML_SF_FZ_RM.gmt -Wthicker,pink -O -K >> $ps
gmt psxy -R -J LIPS.2011.gmt -L -Gpink1@50 -Wthinnest,red -O -K >> $ps
gmt psxy -R -J ophiolites.gmt -Sc0.15c -Gmagenta -Wthinnest -O -K >> $ps
gmt psxy -R -J ridge.gmt -Sf0.5c/0.15c+l+t -Wthin,red -Gyellow -O -K >> $ps
gmt psxy -R -J ridge.gmt -Sc0.05c -Gred -Wthickest,red -O -K >> $ps
# tectonic plates
gmt psxy -R -J TP_Arabian.txt -L -Wthicker,purple -O -K >> $ps
gmt psxy -R -J TP_African.txt -L -Wthickest,purple -O -K >> $ps
#
gmt psmeca -R CMT.txt -J -Sd0.4/2/u -Gred -L0.1p -O -K >> $ps
gmt psmeca -R CMT.txt -J -Sc0.1/2/u -Gred -L0.1p -Fa/5p/it \
    -Fepurple -Fgmagenta -Ft -W0.1p -Fz -Eyellow -O -K >> $ps
gmt psmeca CMT.txt -R -J -Sd0.5/2/u -Gred -L0.1p -Fa/5p/it \
    -Fepurple -Fgmagenta -Ft -F+f8p,Times-Roman,yellow+jLB \
    -W0.1p -Fz -Ewhite -O -K >> $ps

#Texts
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica,brown+jLB >> $ps << EOF
45.0 17.3 A R A B I A N  P L A T E
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica,brown+jLB -Gwhite@60 >> $ps << EOF
44.2 10.8 A F R I C A N   P L A T E
EOF

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
1.2 8.9 Digital relief model: GEBCO/SRTM 15 arc-second grid of Earth's surface
EOF

# Convert to image file using GhostScript
gmt psconvert Geol_YE.ps -A2.5c -E720 -Tj -Z
