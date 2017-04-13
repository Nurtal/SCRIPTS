




def init_variables_files():
	"""
	create 1 file per variable
	each file should contain the synonyms
	of the variable
	"""

	all_variables_file = open("data/header.txt", "r")
	for line in all_variables_file:
		line = line.split("\n")
		line = line[0]
		line_in_array = line.split("\\")

		# define file name
		single_variable_file_name = ""
		for elt in line_in_array:
			single_variable_file_name += str(elt)+"_"
		single_variable_file_name = "variables/"+single_variable_file_name[1:-1]+".txt"
		
		# write file
		single_variable_file = open(single_variable_file_name, "w")
		single_variable_file.close()
	all_variables_file.close()