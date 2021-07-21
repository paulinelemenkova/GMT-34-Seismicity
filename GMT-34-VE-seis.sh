#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Panama)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/wkp/shadowxfox/tn/colombia.png.index.html

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
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R286/300.5/0/12.5 -Gve_relief1.nc
gmt grdcut GEBCO_2019.nc -R286/300.5/0/12.5 -Gve_relief.nc
gdalinfo -stats ve_relief.nc
# Min=-4947.963 Max=5535.625

# Make color palette
# gmt makecpt -Cbone.cpt -V -T-4948/5536 > pauline.cpt
# gmt makecpt -Ccolombia.cpt -V -T-4948/5536 > pauline.cpt
gmt makecpt -Ccolombia.cpt > pauline.cpt
gmt makecpt -Cseis -T1.9/7.3/0.5 -Z > steps.cpt
# srtm dem1, dem2, dem3

ps=Seis_VE.ps
# Make raster image
gmt grdimage ve_relief.nc -Cpauline.cpt -R286/300.5/0/12.5 -JM6.5i -I+a15+ne0.75 -Xc -P -K > $ps

# Add legend
gmt psscale -Dg286/-1.0+w16.5c/0.4c+h+o0.0/0i+ml+e -R -J -Cpauline.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a500+l"Colormap: 'colombia' scheme [−4000 to 5000, discrete, RGB, 14 segments]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour ve_relief1.nc -R -J -C500 -Wthinnest,brown -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,olivedrab1 -Wthin,lightcyan2 -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx4f2a2 -Bpyg4f2a2 -Bsxg4 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=14p,25,black \
    -B+t"Seismicity in Venezuela and Trinidad and Tobago: IRIS database (1997-2021)" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=10p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.0c/-3.6c+c50+w200k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-110p -O -K >> $ps

# Add earthquake points
# separator in numbers of table: dot (.), not comma ! (British style)
gmt psxy -R -J quakes_VE.ngdc -Wfaint -i4,3,6,6s0.05 -h3 -Scc -Csteps.cpt -O -K >> $ps

# Add geological lines and points
gmt psxy -R -J volcanoes.gmt -St0.4c -Gred -Wthinnest -O -K >> $ps
# fabric and magnetic lineation picks fracture zones
gmt psxy -R -J GSFML_SF_FZ_KM.gmt -Wthicker,goldenrod1 -O -K >> $ps
gmt psxy -R -J GSFML_SF_FZ_RM.gmt -Wthicker,pink -O -K >> $ps
#gmt psxy -R -J LIPS.2011.gmt -L -Gpink1@70 -Wthinnest,red -O -K >> $ps
gmt psxy -R -J ridge.gmt -Sf0.5c/0.15c+l+t -Wthick,red -Gyellow -O -K >> $ps
gmt psxy -R -J ridge.gmt -Sc0.05c -Gred -Wthickest,red -O -K >> $ps
# tectonic plates
gmt psxy -R -J TP_Caribbean.txt -L -Wthickest,purple -O -K >> $ps
gmt psxy -R -J TP_Cocos.txt -L -Wthickest,purple -O -K >> $ps
gmt psxy -R -J TP_Nazca.txt -L -Wthickest,purple -O -K >> $ps
gmt psxy -R -J TP_South_Am.txt -L -Wthickest,purple -O -K >> $ps

# Texts

gmt pslegend -R -J -Dx1.5/-3.0+w17.8c+o-2.0/0.1c \
    -F+pthin+ithinner+gwhite \
    --FONT=8p,black -O -K << FIN >> $ps
H 10 Helvetica Seismicity: earthquakes magnitude (M) from 1.9 to 7.3
N 9
S 0.3c c 0.3c red 0.01c 0.5c M (7.1-7.3)
S 0.3c c 0.3c tomato 0.01c 0.5c M (6.4-7.0)
S 0.3c c 0.3c orange 0.01c 0.5c M (5.6-6.3)
S 0.3c c 0.3c yellow 0.01c 0.5c M (4.8-5.5)
S 0.3c c 0.3c chartreuse1 0.01c 0.5c M (4.1-4.7)
S 0.3c c 0.3c chartreuse1 0.01c 0.5c M (3.4-4.0)
S 0.3c c 0.3c cyan3 0.01c 0.5c M (2.7-3.3)
S 0.3c c 0.3c blue 0.01c 0.5c M (1.9-2.6)

S 0.3c t 0.3c red 0.03c 0.5c Volcanoes
FIN

# Add GMT logo
gmt logo -Dx7.0/-4.5+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.9c -N -O \
    -F+f11p,25,black+jLB >> $ps << EOF
1.0 13.6 DEM: SRTM/GEBCO, 15 arc sec grid. Earthquakes: IRIS Seismic Event Database
EOF

# Convert to image file using GhostScript
gmt psconvert Seis_VE.ps -A1.7c -E720 -Tj -Z
