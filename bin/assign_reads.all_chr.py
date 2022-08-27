import sys
import re

#chr22   16797874        16797878        A
#chr22   16798285        16798289        A
#chr22   16798883        16798887        A
#chr22   16799014        16799018        A
#chr22   16799608        16799612        T

#A01577:10:H23FVDSX3:1:1416:18059:25160  83      chr22   16797748        60      150M    =       16797363        -535    GCACCACTGCACTCCAGCCTGGGCGACAGAGTGAGACTCTGTCTC
#A01577:10:H23FVDSX3:4:2244:10972:22592  83      chr22   16797748        60      149M    =       16797531        -366    GCACCACTGCACTCCAGCCTGGGCGACATAGTGAGACTCTGTATA
#A01577:10:H23FVDSX3:2:2532:18394:32659  99      chr22   16797749        60      44M1D106M       =       16798205        606     CACCACTGCACTCCAGCCTGGGCGACAGAGTGAGACT

MS_f = open(sys.argv[1])
target_chr_d = {}
for line in MS_f:
	line = line.replace("\n", "")
	line_l = line.split("\t")

	target_chr_d[line_l[0]] = 1
MS_f.close()

for chr_tmp in target_chr_d:
	MS_f = open(sys.argv[1])
	MS_l = []
#target_chr = ""
	for line in MS_f:
		line = line.replace("\n", "")
		line_l = line.split("\t")

		if line_l[0] != chr_tmp:
			continue

		target_chr = line_l[0]
		MS_l.append([int(line_l[1]), int(line_l[2]), line_l[3]])
	MS_f.close()
#print("MS_l", MS_l)

	f = open(sys.argv[2])
	MS_read_d = {}
	for line in f:
		line = line.replace("\n", "")
		line_l = line.split("\t")

		if line_l[2] != target_chr:
			continue

#	print(line)

#	if "A01577:10:H23FVDSX3:4:1633:9932:25363" in line:
#		print(line)

		cigar_type1 = re.split(r'\d+', line_l[5])
		cigar_len1 = re.split(r'[a-zA-Z]+', line_l[5])
		del cigar_type1[0]
		del cigar_len1[-1]

#	print("cigar_type1", cigar_type1)
#	print("cigar_len1", cigar_len1)

		total_length = 0
		for i in range(len(cigar_type1)):
#		print(cigar_type1[i], cigar_len1[i])

			if cigar_type1[i] == "M":
				total_length += int(cigar_len1[i])
			elif cigar_type1[i] == "D":
				total_length += int(cigar_len1[i])

		end_pos = int(line_l[3]) + total_length - 1
#	print("start", line_l[3], "end", end_pos)

		pop_list = 0
		for pos_l in MS_l:
			if pos_l[1] < int(line_l[3]):
				pop_list = 1
				continue
			if int(line_l[3]) <= pos_l[0] <= end_pos or int(line_l[3]) <= pos_l[1] <= end_pos or pos_l[0] <= end_pos <= pos_l[1]:
				if not str(pos_l[0]) + "\t" + str(pos_l[1]) in MS_read_d:
					MS_read_d[str(pos_l[0]) + "\t" + str(pos_l[1])] = [line]
				else:
					MS_read_d[str(pos_l[0]) + "\t" + str(pos_l[1])].append(line)
			if end_pos < pos_l[0]:
				break

		if pop_list:
			num = 0
			for pos_l in MS_l:
				if pos_l[1] < int(line_l[3]):
					if str(pos_l[0]) + "\t" + str(pos_l[1]) in MS_read_d:
#					print(target_chr + ":" + str(pos_l[0]) + "-" + str(pos_l[1]), len(MS_read_d[str(pos_l[0]) + "\t" + str(pos_l[1])]))
#					print("#########")
						print("#" + target_chr + ":" + str(pos_l[0]) + "-" + str(pos_l[1]) + "\t" + pos_l[2], flush=True)
#				print(len(MS_read_d[str(pos_l[0]) + "\t" + str(pos_l[1])]))
						for read_tmp in MS_read_d[str(pos_l[0]) + "\t" + str(pos_l[1])]:
							print(read_tmp, flush=True)
							read_tmp_l = read_tmp.split("\t")
#					print(read_tmp_l[0])
#						pass
						print("==========", flush=True)
						del MS_read_d[str(pos_l[0]) + "\t" + str(pos_l[1])]
						num += 1
					else:
#					print(target_chr + ":" + str(pos_l[0]) + "-" + str(pos_l[1]), 0)
						num += 1

				if end_pos < pos_l[0]:
					break

			del MS_l[:num]
