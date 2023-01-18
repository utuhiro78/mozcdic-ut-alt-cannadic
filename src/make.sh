#!/bin/bash

# Author: UTUMI Hirosi (utuhiro78 at yahoo dot co dot jp)
# License: Apache License, Version 2.0

ruby convert_alt_cannadic_to_mozcdic.rb

tar cjf mozcdic-ut-alt-cannadic.txt.tar.bz2 mozcdic-ut-alt-cannadic.txt
mv mozcdic-ut-alt-cannadic.txt* ../

rm -rf ../../mozcdic-ut-alt-cannadic-release/
rsync -a ../* ../../mozcdic-ut-alt-cannadic-release --exclude=alt-cannadic* --exclude=mozcdic-ut-*.txt