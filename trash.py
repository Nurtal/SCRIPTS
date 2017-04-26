
def forgotten_stuff():
	"""
	"""

	flow_var_index = []
	patient_id_index = -1
	disease_index = -1 

	input_data_file_name = "data/phase_1.txt"
	input_data_file = open(input_data_file_name, "r")
	cmpt = 0
	for line in input_data_file:
		line = line.split("\n")
		line = line[0]
		line_in_array = line.split("\t")

		if(cmpt == 0):
			index = 0
			for var in line_in_array:
				var_in_array = var.split("\\")
				if(len(var_in_array) > 2):
					if(var_in_array[1] == "Flow cytometry"):
						flow_var_index.append(index)

				if(var == "\\Clinical\\Sampling\\OMICID"):
					patient_id_index = index

				if(var == "\\Clinical\\Diagnosis\\DISEASE"):
					disease_index = index

				index += 1

		cmpt += 1
	input_data_file.close()



	input_data_file_name = "data/phase_1.txt"
	output_data_file_name = "data/flow_data_phase_1.txt"
	input_data_file = open(input_data_file_name, "r")
	output_data_file = open(output_data_file_name, "w")
	cmpt = 0
	for line in input_data_file:
		line = line.split("\n")
		line = line[0]
		line_in_array = line.split("\t")

		line_to_write = ""

		index = 0
		for var in line_in_array:

			var = var.replace(" ", "")

			var_in_array = var.split("\\")
			
			if(index in flow_var_index):
				line_to_write += str(var) +","

			if(index == patient_id_index):
				line_to_write += str(var) +","

			if(index == disease_index):
				line_to_write += str(var) +","

			index += 1

		line_to_write = line_to_write[:-1]
		output_data_file.write(line_to_write+"\n")

		cmpt += 1
	output_data_file.close()
	input_data_file.close()




# reformat data for the discretization process

input_data = open("C:\\Users\\PC_immuno\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\data\\test.txt", "r")
output_data = open("C:\\Users\\PC_immuno\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\data\\test_2.txt", "w")
for line in input_data:
	line = line.split("\n")
	line = line[0]
	line_in_array = line.split(",")

	line_to_write = ""

	index = 0
	for scalar in line_in_array:

		scalar = scalar.replace(" ", "")
		scalar = scalar.replace("\"", "")
		
		line_to_write += str(scalar) +","

		index += 1 

	line_to_write = line_to_write[:-1]

	output_data.write(line_to_write+"\n")

output_data.close()
input_data.close()
