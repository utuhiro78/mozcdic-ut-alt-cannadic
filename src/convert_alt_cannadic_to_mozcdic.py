#!/usr/bin/env python
# coding: utf-8

# Author: UTUMI Hirosi (utuhiro78 at yahoo dot co dot jp)
# License: Apache License, Version 2.0

import re
import tarfile
import urllib.request
from unicodedata import normalize

urllib.request.urlretrieve('https://ftp.iij.ad.jp/pub/osdn.jp/alt-cannadic/50881/alt-cannadic-110208.tar.bz2', 'alt-cannadic-110208.tar.bz2')

with tarfile.open("alt-cannadic-110208.tar.bz2") as tar:
    file = tar.extractfile("alt-cannadic-110208/gcanna.ctd")
    lines = file.read().decode("euc_jp")
    file = tar.extractfile("alt-cannadic-110208/g_fname.ctd")
    lines = lines + file.read().decode("euc_jp")

lines = lines.splitlines()

# Mozc の一般名詞のID
url = "https://raw.githubusercontent.com/google/mozc/master/src/data/dictionary_oss/id.def"
with urllib.request.urlopen(url) as response:
    id_mozc = response.read().decode()

id_mozc = id_mozc.split(" 名詞,一般,")[0].split("\n")[-1]

dict_name = "mozcdic-ut-alt-cannadic.txt"
l2 = []

for i in range(len(lines)):
    entry = lines[i].split(" ")

    # あきびん #T35*202 空き瓶 空瓶 #T35*151 空きビン 空ビン
    yomi = entry[0]
    yomi = yomi.replace("う゛", "ゔ")

    # 読みがひらがな以外を含む場合はスキップ
    # 読みが2文字以下の場合はスキップ
    if yomi != ''.join(re.findall('[ぁ-ゔー]', yomi)) or \
            len(yomi) < 3:
        continue

    hinsi = ""
    cost_anthy = 0

    # 読みを抜いたエントリを作る
    entry = entry[1:]

    for c in range(len(entry)):
        # alt-cannadic の品詞とコストを取得
        # #T35*202 空き瓶 空瓶 #T35*151 空きビン 空ビン
        if entry[c][0] == "#":
            s1 = entry[c].split("*")
            hinsi = s1[0]
            cost_anthy = int(s1[1])
            continue

        hyouki = entry[c]
        hyouki = normalize("NFKC", hyouki)

        # 表記が1文字の場合はスキップ
        if len(hyouki) < 2:
            continue

        # alt-cannadic のコストから Mozc 辞書のコストを作る
        # 「#T35*202 空き瓶 空瓶 #T35*151 空きビン 空ビン」の場合、
        # 「空き瓶 空瓶 空きビン 空ビン」の順に優先されるようにする。
        # Mozc 辞書でのコストは 8000 台にする。
        cost_mozc = (9000 - cost_anthy) + c

        # 収録する品詞を選択
        if hinsi.startswith("#T3") or \
                hinsi.startswith("#T0") or \
                hinsi.startswith("#JN") or \
                hinsi.startswith("#KK") or \
                hinsi.startswith("#CN"):
            s1 = [yomi, hyouki, id_mozc, id_mozc, str(cost_mozc)]
            l2.append("\t".join(s1))

lines = sorted(l2)
l2 = []

with open(dict_name, "w", encoding="utf-8") as dict_file:
    dict_file.write("")

for i in range(len(lines)):
    entry1 = lines[i].split("\t")
    entry2 = lines[i - 1].split("\t")

    if entry1[:2] == entry2[:2]:
        continue

    entry1.append(entry1[1])
    entry1.pop(1)

    l2.append("\t".join(entry1) + "\n")

lines = sorted(l2)
l2 = []

with open(dict_name, "a", encoding="utf-8") as dict_file:
    dict_file.writelines(lines)
