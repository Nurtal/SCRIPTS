
data_filename = "rules_SjS.txt"
new_data_file_name = data_filename.split(".")
new_data_file_name = new_data_file_name[0]+"_filtered.txt"
support_treshold = 0.07
confidence_treshold = 0.85
lift_treshold = 8


input_data = open("data/"+str(data_filename), "r")
output_data = open("data/"+str(new_data_file_name), "w")
cmpt = 0
rule = "undef"
support = "undef"
confidence = "undef"
lift = "undef"
rules_keep_counter = 0
for line in input_data:

	line = line.split("\n")
	line = line[0]

	line_in_array = line.split(";")


	if(cmpt > 0):
		rule = line_in_array[1]
		support = line_in_array[2]
		confidence = line_in_array[3]
		lift = line_in_array[4]


		if(float(support) >= float(support_treshold) and float(confidence) >= float(confidence_treshold) and float(lift) >= float(lift_treshold)):
			output_data.write(line+"\n")
			rules_keep_counter += 1

	cmpt += 1

output_data.close()
input_data.close()


number_of_rules = cmpt - 1

print "=> "+str(rules_keep_counter) +" rules kept"  