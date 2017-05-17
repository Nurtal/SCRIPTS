
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




def reformat_for_discretization():
	"""
	reformat data for the discretization process
	"""
	input_data = open("data/discretization_data_to_process.txt", "r")
	output_data = open("data/discretization_data_processed.txt", "w")
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



def reformat_selected_variables():
	"""
	reformat selected variable for rules extratction
	"""

	input_data = open("data/feature_selection_diag_RA.txt", "r")
	output_data = open("data/feature_selection_diag_RA_formated.txt", "w")

	for line in input_data:
		line = line.split("\n")
		line = line[0]

		line_in_array = line.split(";")
		scalar_to_write = line_in_array[0]
		scalar_to_write = scalar_to_write.replace("\"", "")

		if(line_in_array[-1] == "\"Confirmed\""):
			output_data.write(scalar_to_write+"\n")

	input_data.close()
	output_data.close()




def convert_NA_disease_to_Control(input_file_name):
	"""
	pretty much what it's said
	"""
	output_file_name = input_file_name.split(".")
	output_file_name = output_file_name[0]+"with_control.csv"

	disease_index = -1

	input_data = open(input_file_name, "r")
	output_data = open(output_file_name, "w")
	cmpt = 0
	for line in input_data:
		line = line.split("\n")
		line = line[0]
		line_in_array = line.split(",")
		
		if(cmpt == 0):
			index = 0
			for variable in line_in_array:
				if(variable == "\\Clinical\\Diagnosis\\DISEASE"):
					disease_index = index
				index += 1

			output_data.write(line+"\n")

		else:
			index = 0
			line_to_write = ""
			for scalar in line_in_array:

				if(index == disease_index):
					disease_to_write = scalar
					if(scalar == "NA"):
						disease_to_write = "Control"

					line_to_write += str(disease_to_write)+","
				else:
					line_to_write += str(scalar)+","

				index += 1

			line_to_write = line_to_write[:-1]
			output_data.write(line_to_write+"\n")

		cmpt +=1

	output_data.close()
	input_data.close()



"""EXECUTE SPACE"""
#convert_NA_disease_to_Control("data/flow_data_phase_1.txt")
reformat_for_discretization()