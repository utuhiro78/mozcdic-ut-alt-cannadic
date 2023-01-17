---
title: Mozc UT Alt-Cannadic Dictionary
date: 2023-01-18
---

## Overview

Mozc UT Alt-Cannadic Dictionary is a dictionary converted from [Alt-Cannadic](https://ja.osdn.net/projects/alt-cannadic/) for Mozc.

Thanks to the Alt-Cannadic team.

## License

mozcdic-ut-alt-cannadic.txt: GPL-2.0

Source code: Apache License, Version 2.0

```
head -n 10 alt-cannadic-110208/COPYING

		    GNU GENERAL PUBLIC LICENSE
		       Version 2, June 1991
```

## Usage

Add mozcdic-ut-*.txt to dictionary00.txt and build Mozc as usual.

```
tar xf mozcdic-ut-*.txt.tar.bz2
cat ../mozc-master/src/data/dictionary_oss/dictionary00.txt mozcdic-ut-*.txt > dictionary00.txt.new
mv dictionary00.txt.new ../mozc-master/src/data/dictionary_oss/dictionary00.txt
```

Except for mozcdic-ut-jawiki, the costs are not modified by jawiki-latest-all-titles.

To modify the costs or merge multiple UT dictionaries into one, use the following tool:

[merge-ut-dictionaries](https://github.com/utuhiro78/merge-ut-dictionaries)

## If you create your own UT dictionary

Requirement(s): ruby, rsync

```
cd src/
sh make.sh
```

[HOME](http://linuxplayers.g1.xrea.com/mozc-ut.html)
