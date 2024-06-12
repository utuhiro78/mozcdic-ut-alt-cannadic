#! /usr/bin/env ruby
# coding: utf-8

# Author: UTUMI Hirosi (utuhiro78 at yahoo dot co dot jp)
# License: Apache License, Version 2.0

require 'nkf'
require 'open-uri'

`wget -nc https://ja.osdn.net/dl/alt-cannadic/alt-cannadic-110208.tar.bz2`
`rm -rf alt-cannadic-110208`
`tar xf alt-cannadic-110208.tar.bz2`
`cat alt-cannadic-110208/gcanna.ctd alt-cannadic-110208/g_fname.ctd > mozcdic-ut-alt-cannadic.txt`

filename = "mozcdic-ut-alt-cannadic.txt"
dicname = filename

file = File.new(filename, "r")
	lines = file.read
file.close

# EUC-JP から UTF-8 に変換し、全角英数は半角にする
lines = NKF.nkf('-JE -jw -Z', lines)
lines = lines.split("\n")

# 確認用に出力
dicfile = File.new("alt-cannadic.txt.utf8", "w")
	dicfile.puts lines
dicfile.close

l2 = []
p = 0

lines.length.times do |i|
	s1 = lines[i].chomp.split(" ")

	# あきびん #T35*202 空き瓶 空瓶 #T35*151 空きビン 空ビン
	yomi = s1[0]
	yomi = yomi.gsub("う゛", "ゔ")

	# 読みがひらがな以外を含む場合はスキップ
	if yomi != yomi.scan(/[ぁ-ゔー]/).join ||
	# 読みが2文字以下の場合はスキップ
	yomi[2] == nil
		next
	end

	hinsi = ""
	cost_anthy = ""

	# 読みを抜いたエントリを作る
	s1 = s1[1..-1]

	s1.length.times do |c|
		# alt-cannadic の品詞とコストを取得
		# #T35*202
		if s1[c][0] == "#"
			t1 = s1[c].split("*")
			hinsi = t1[0]
			cost_anthy = t1[1].to_i
			next
		end

		hyouki = s1[c]

		# 表記が1文字の場合はスキップ
		if hyouki[1] == nil
			next
		end

		# alt-cannadic のコストから Mozc 辞書のコストを作る
		# 「#T35*202 空き瓶 空瓶 #T35*151 空きビン 空ビン」の場合、
		# 「空き瓶 空瓶 空きビン 空ビン」の順に優先されるようにする。
		# Mozc 辞書でのコストは 8000 台にする。
		cost_mozc = (9000 - cost_anthy) + c

		# 収録する品詞を選択
		if hinsi.index("#T3") == 0 ||
		hinsi.index("#T0") == 0 ||
		hinsi.index("#JN") == 0 ||
		hinsi.index("#KK") == 0 ||
		hinsi.index("#CN") == 0
			l2[p] = [yomi, hyouki, cost_mozc.to_s]
			l2[p] = l2[p].join("	")
			p = p + 1
		end
	end
end

lines = l2
l2 = []
lines = lines.sort

# Mozc の一般名詞のID
url = "https://raw.githubusercontent.com/google/mozc/master/src/data/dictionary_oss/id.def"
id_mozc = URI.open(url).read.split(" 名詞,一般,")[0]
id_mozc = id_mozc.split("\n")[-1]

p = 0

lines.length.times do |i|
	s1 = lines[i].chomp.split(" ")
	s2 = lines[i - 1].chomp.split(" ")

	# 「読み..表記」が前のエントリと重複する場合はスキップ
	if s1[0..1] == s2[0..1]
		next
	end

	# あきびん	空き瓶	8798
	l2[p] = [s1[0], id_mozc, id_mozc, s1[2], s1[1]]
	l2[p] = l2[p].join("	")
	p = p + 1
end

lines = l2
l2 = []

lines = lines.sort

dicfile = File.new(dicname, "w")
	dicfile.puts lines
dicfile.close
