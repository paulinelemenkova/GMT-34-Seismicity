#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Cuba)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/njgs/index.html

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

exec bash

cd /Users/polinalemenkova/
tr ',' '\t' < IEB_export_Cuba.csv > IEB_export_Cuba.tsv

#chsh -s /bin/zsh
#chsh -s /bin/bash
# Extract a subset of ETOPO1m for the study area
gmt grdcut ETOPO1_Ice_g_gmt4.grd -R275/287/19/24 -Gcu_relief.nc
gmt grdcut GEBCO_2023.nc -R275/287/19/24 -Gcu_relief.nc
gmt grdinfo cu_relief1.nc
# Minimum=-7337.000, Maximum=1854.000, Mean=-2772.105, StdDev=2341.131

# Make color palette
gmt makecpt -Cgmt/relief -V -T-7337/1854 > myocean.cpt
# elevation etopo1 world elevation dem1 dem2 dem3 globe geo srtm turbo terra earth relief costa-rica
gmt makecpt -Cseis -T3.0/8.0/0.1 -Z > steps.cpt

ps=Seis_CU.ps
# Make image
gmt grdimage cu_relief.nc -Cmyocean.cpt -R275/287/19/24 -JM6.0i -I+a15+ne0.75 -Xc -P -K > $ps
# Add isolines
gmt grdcontour cu_relief.nc -R -J -C1000 -A1000+f7p,26,white -Wthinner,aliceblue -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thicker,red -W0.1p -Df -O -K >> $ps
    
# Add color legend
gmt psscale -Dg275.0/18.1+w15.0c/0.15i+h+o0.3/0i+ml+e -R -J -Cmyocean.cpt \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
    -Bg500f50a1000+l"Colormap: 'GMT relief', [R=-7337/1854, H, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg4f2a2 -Bpyg2f4a2 -Bsxg2 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_LABEL=8p,25,black \
    --FONT_TITLE=14p,25,black \
    -B+t"Seismicity of Cuba on the topographic map" -O -K >> $ps
    
# Add scalebar, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx12.8c/-2.3c+c10+w400k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

# Add earthquake points
#gmt psxy -R -J quakes_PCT.csv -Wfaint -i4,3,6,6s0.1 -h3 -Scc -Csteps.cpt -O -K >> $ps
gmt psxy -R -J IEB_export_Cuba.tsv -Wfaint -i4,3,6,6s0.1 -h3 -Scc -Csteps.cpt -O -K >> $ps

# Texts -R275/287/19/24 -Gwhite@40
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,1,darkred+jLB+a-350 >> $ps << EOF
278 19.2 Cayman Trough
EOF
gmt psxy -R -J TP_Caribbean.txt -L -Wthick,red -O -K >> $ps
gmt psxy -R -J TP_North_Am.txt -L -Wthick,red -O -K >> $ps

# insert map
# Countries codes: ISO 3166-1 alpha-2. Continent codes AF (Africa), AN (Antarctica), AS (Asia), EU (Europe), OC (Oceania), NA (North America), or SA (South America). -EEU+ggrey
gmt psbasemap -R -J -O -K -DjTR+w2.5c+stmp >> $ps
read x0 y0 w h < tmp
gmt pscoast --MAP_GRID_PEN_PRIMARY=thinnest,dimgray -Rg -JG280/21/$w -Da -Glightgoldenrod1 -A5000 -Bga -Wfaint -ECU+gred -Slightskyblue -O -K -X$x0 -Y$y0 >> $ps
gmt psxy -R -J -O -K -T  -X-${x0} -Y-${y0} >> $ps

gmt pslegend -R -J -Dx1.5/-3.1+w16.5c+o-2.0/0.1c \
    -F+pthin+ithinner+gwhite \
    --FONT=8p,black -O -K << FIN >> $ps
H 9 Helvetica Seismicity: earthquakes magnitude (M), range from 3.0 to 8.0
N 9
S 0.3c c 0.3c red1 0.01c 0.5c M (3.0-3.8)
S 0.3c c 0.3c sienna1 0.01c 0.5c M (3.8-4.4)
S 0.3c c 0.3c darkorange1 0.01c 0.5c M (4.4-5.0)
S 0.3c c 0.3c yellow2 0.01c 0.5c M (5.0-5.5)
S 0.3c c 0.3c olivedrab1 0.01c 0.5c M (5.5-6.1)
S 0.3c c 0.3c green1 0.01c 0.5c M (6.1-6.6)
S 0.3c c 0.3c dodgerblue2 0.01c 0.5c M (6.6-7.1)
S 0.3c c 0.3c blue 0.01c 0.5c M (7.1-8.0)
FIN

# Add GMT logo
gmt logo -Dx6.0/-4.3+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y1.5c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
2.5 9.0 Data cretits: USGS (seismicity), GEBCO/SRTM (topography)
EOF

# Convert to image file using GhostScript
gmt psconvert Seis_CU.ps -A1.5c -E720 -Tj -Z
