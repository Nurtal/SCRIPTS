


input_data = open("Luminex_data.csv", "r")
output_data = open("Luminex_SjS_Ctrl.csv", "w")

cmpt = 0
for line in input_data:

	line = line.replace("\"", "")

	if(cmpt == 0):
		output_data.write(line)
	else:
		line_in_array = line.split(",")
		diag = line_in_array[0]

		if(diag in ["control", "SjS"]):

			line_to_write = ""
			index = 0
			for scalar in line_in_array:				
				if(index == 0):
					if(diag == "control"):
						scalar = 0
					elif(diag == "SjS"):
						scalar = 1
				index+=1

				line_to_write += str(scalar)+","

			line_to_write = line_to_write[:-1]
			output_data.write(line_to_write+"\n")

	cmpt += 1

output_data.close()
input_data.close()