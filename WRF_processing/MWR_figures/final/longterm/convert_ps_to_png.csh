#!/bin/tcsh -f

foreach input_name (`ls *.ps | sed 's/\.ps//g'`)
    
  convert -density 400 -trim -bordercolor white -border 25 $input_name.ps -resize 25% -quality 92 -rotate -90 $input_name'.png'


end

