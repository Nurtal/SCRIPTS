


disease_index = -1
list_of_disease = []

variables_to_values = {}
selected_variable_file_name = "data/selected_variables.txt"
selected_variables_file = open(selected_variable_file_name, "r")
for line in selected_variables_file:
	line = line.split("\n")
	line = line[0]
	variables_to_values[line] = []
selected_variables_file.close()


variables_to_index = {}
input_file_name = "data/clinical_data_phase_1.csv"
data = open(input_file_name, "r")
cmpt = 0
for line in data:
	line = line.split("\n")
	line = line[0]
	line_in_array = line.split(",")

	if(cmpt == 0):
		index = 0
		for var in line_in_array:

			if(var == "\\Clinical\\Diagnosis\\DISEASE"):
				disease_index = index

			for key in variables_to_values.keys():
				formated_key = key.replace(".", "\\")
				if(formated_key[1:] == var):
					variables_to_index[key] = index
			index +=1		
	cmpt += 1
data.close()


input_file_name = "data/clinical_data_phase_1.csv"
data = open(input_file_name, "r")
cmpt = 0
for line in data:
	line = line.split("\n")
	line = line[0]
	line_in_array = line.split(",")

	

	if(cmpt != 0):

		patient_disease = line_in_array[disease_index]
		if(patient_disease not in list_of_disease):
			list_of_disease.append(patient_disease)

		index = 0
		for var in line_in_array:
			for key in variables_to_values.keys():
				formated_key = key.replace(".", "\\")
				if(index == variables_to_index[key]):
					
					if(var not in variables_to_values[key]):
						variables_to_values[key].append(var)

			index +=1		
	cmpt += 1
data.close()

variables_to_values_to_count = {}
for key in variables_to_values.keys():
	values_to_count = {}
	for value in variables_to_values[key]:
		disease_to_count = {}
		for disease in list_of_disease:
			disease_to_count[disease] = 0
		values_to_count[value] = disease_to_count
	variables_to_values_to_count[key] = values_to_count


input_file_name = "data/clinical_data_phase_1.csv"
data = open(input_file_name, "r")
cmpt = 0
header = "undef"
for line in data:
	line = line.split("\n")
	line = line[0]
	line_in_array = line.split(",")
	patient_disease = line_in_array[disease_index]

	if(cmpt == 0):
		header = line_in_array

	if(cmpt != 0):
		index = 0
		for var in line_in_array:
			if(index in variables_to_index.values()):
				reformated_key = header[index].replace("\\", ".")
				variables_to_values_to_count["X"+reformated_key][var][patient_disease] += 1
			index +=1		
	cmpt += 1
data.close()



import matplotlib.pyplot as plt

for variable in variables_to_values_to_count.keys():

	graphe_title = variable

	for values in variables_to_values_to_count[variable]:

		plt.bar(range(len(variables_to_values_to_count[variable][values])), variables_to_values_to_count[variable][values].values())
		plt.xticks(range(len(variables_to_values_to_count[variable][values])), variables_to_values_to_count[variable][values].keys())
		plt.show()