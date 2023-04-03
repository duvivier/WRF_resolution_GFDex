#! /bin/tcsh -f

find . -print0 | xargs -r0 touch

