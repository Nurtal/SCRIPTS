"""
Objective: a script
to perform all the differents steps involved
in the rule generation process

format data
discretization
features selection
rule generation
report
"""

import shutil
import subprocess
import sys


def detect_file_format(data_file_name):
	"""
	Because in biology, you always need to check
	if a csv file is a real csv file ...
	
	-> Should return the separator used in
	data file.

	[IN PROGRESS]
	"""

	## A few parameters
	can_analyse_file = False
	separator_list = [",", ";", "\t"]
	separator_to_count = {}
	best_separator = "undef"

	## Count the Number of line in the file
	data_file = open(str(data_file_name), "r")
	cmpt_line = 0
	for line in data_file:
		line = line.split("\n")
		line = line[0]
		cmpt_line += 1
	data_file.close()

	## Test if we can do something with it
	if(cmpt_line > 1):
		can_analyse_file = True

	## Run the analysis if we can
	if(can_analyse_file):
		

		## Initialize the separator_to_count variable:
		for separator in separator_list:
			separator_to_count[separator] = []

		## Re-open the file and parse the lines
		data_file = open(str(data_file_name), "r")
		for line in data_file:
			line = line.split("\n")
			line = line[0]

			## Split line with a few separator
			for separator in separator_list:
				line_in_array = line.split(separator)
				separator_to_count[separator].append(len(line_in_array))


		data_file.close()

		## Perform the analysis
		for separator in separator_to_count.keys():

			## Separate data and header size
			## Because biologists ... well, you know why.
			header_size = separator_to_count[separator][0]
			data_size = separator_to_count[separator][1:]

			max_size = max(data_size)
			min_size = min(data_size)

			## Perform the test
			if(max_size != 1 and max_size == min_size):
				 best_separator = separator

		## return the best separator found
		return best_separator


	## Exit The programm with a warning message
	else:
		print "[!] Less than 2 lines in the file"+str(data_file_name)+", can't run an analysis\n"



def reformat_HLA_raw_data():
	"""
	-> use data from Phase 1 to generate
	a clean csv file with only HLA data, OMICID and
	DISEASE for each patient.
	-> input file is data/clinical_i2b2trans_1.txt
	-> output file is data/HLA_phase_I_raw_data.csv
	-> Convert NA values for DISEASE into Control IF patient
	   is marked as Control in diagnosis\\ARM variable.
	"""

	case_index = -1
	omicid_index = -1
	disease_index = -1
	hla_index = []

	## Get the index of variable to keep
	input_data_file = open("data/clinical_i2b2trans_1.txt", "r")
	cmpt = 0
	for line in input_data_file:
		line = line.split("\n")
		line = line[0]
		line_in_array = line.split("\t")

		if(cmpt == 0):			
			index = 0
			for variable in line_in_array:
				variable_in_array = variable.split("\\")
				if("HLA" in variable_in_array):
					hla_index.append(index)
				elif("OMICID" in variable_in_array):
					omicid_index = index
				elif("DISEASE" in variable_in_array):
					disease_index = index
				elif("ARM" in variable_in_array):
					case_index = index
				index += 1
		cmpt += 1
	input_data_file.close()


	## Generate a new file with only
	## the variables we want.
	input_data_file = open("data/clinical_i2b2trans_1.txt", "r")
	output_data_file = open("data/HLA_phase_I_raw_data.csv", "w")
	cmpt = 0
	for line in input_data_file:
		line = line.split("\n")
		line = line[0]
		line_in_array = line.split("\t")

		line_to_write = ""
		index = 0
		for element in line_in_array:
			element_formated = element.replace("\t", "")
			element_formated = element_formated.replace(" ", "")
			if(index in hla_index):
				line_to_write += str(element_formated) +","
			elif(index == omicid_index):
				line_to_write += str(element_formated) +","
			elif(index == disease_index):
				if(element_formated == "NA"):
					case_status = line_in_array[case_index]
					case_status = case_status.replace("\t", "")
					case_status = case_status.replace(" ", "")
					if(case_status == "Control"):
						element_formated = "Control"
				line_to_write += str(element_formated) +","			
			index +=1

		line_to_write = line_to_write[:-1]
		output_data_file.write(line_to_write+"\n")
	output_data_file.close()
	input_data_file.close()

	## log message
	print "[+] HLA data extracted"



def check_NA_proportion_in_file(data_file_name):
	"""
	-> data_file_name is a csv file, generate via the 
	   reformat_luminex_raw_data() function
	-> Evaluate the proportion of NA values in each variable
	-> return a dictionnary
	"""

	position_to_variable = {}
	variable_to_NA_count = {}

	## Count NA values for each variable
	## in data file.
	cmpt = 0
	input_data = open(data_file_name, "r")
	for line in input_data:
		line = line.split("\n")
		line = line[0]
		line_in_array = line.split(",")
		
		if(cmpt == 0):
			index = 0
			for variable in line_in_array:
				position_to_variable[index] = variable
				variable_to_NA_count[variable] = 0
				index +=1
		else:
			index = 0
			for scalar in line_in_array:
				if(scalar == "NA"):
					variable_to_NA_count[position_to_variable[index]] += 1
				index+=1

		cmpt += 1
	input_data.close()

	## Compute the %
	for key in variable_to_NA_count.keys():
		variable_to_NA_count[key] = float((float(variable_to_NA_count[key]) / float(cmpt)) * 100)

	## return dict
	return variable_to_NA_count


def filter_NA_values(data_file_name):
	"""
	-> Evaluate the proportion of NA values in each variable
	   (use the check_NA_proportion_in_file() function).
	-> Find the minimum proportion of NA (minimum_score, i.e almost
		patient have non NA values for this feature, except a few ones
		wich have a lot of NA)
	-> Rewrite a file (data/Luminex_phase_I_raw_data_filtered.csv) with only
	   the selected variables
	"""

	## Structure initialization
	score_list = []
	variable_saved = []

	## Get information on NA proportion in data file
	variable_to_NA_proportion = check_NA_proportion_in_file(data_file_name)

	## find minimum score of NA among variables
	## Exluding OMICID and DISEASE (every patient should have one)
	for key in variable_to_NA_proportion.keys():
		if(key != "\\Clinical\\Sampling\\OMICID" and key != "\\Clinical\\Diagnosis\\DISEASE"):
			score_list.append(variable_to_NA_proportion[key])
	minimum_score = min(score_list)

	## Use minimum score as a treshold for
	## selecting variables
	for key in variable_to_NA_proportion.keys():
		if(float(variable_to_NA_proportion[key]) > float(minimum_score)):
			variable_saved.append(key)

	## Log message
	print "[+] Selecting "+str(len(variable_saved))+" variables among "+str(len(variable_to_NA_proportion.keys())) +" ["+str((float(len(variable_to_NA_proportion.keys()))-float(len(variable_saved))) / float(len(variable_to_NA_proportion.keys()))*100)+"%]"

	## Create a new filtered data file
	index_to_keep = []
	cmpt = 0
	input_data_file = open(data_file_name, "r")
	output_data_file = open("data/Luminex_phase_I_raw_data_filtered.csv", "w")
	for line in input_data_file:
		line = line.split("\n")
		line = line[0]
		line_in_array = line.split(",")
		if(cmpt == 0):
			header_in_line = ""
			index = 0
			for variable in line_in_array:
				score = float(variable_to_NA_proportion[variable])
				if(score <= minimum_score):
					header_in_line += str(variable) +","
					index_to_keep.append(index)
				index +=1
			header_in_line = header_in_line[:-1]
			output_data_file.write(header_in_line+"\n")
		else:
			line_to_write = ""
			index = 0
			for scalar in line_in_array:
				if(index in index_to_keep):
					line_to_write += str(scalar) + ","
				index += 1

			line_to_write = line_to_write[:-1]
			output_data_file.write(line_to_write+"\n") 
		cmpt += 1
	output_data_file.close()
	input_data_file.close()




def reformat_luminex_raw_data():
	"""
	-> use data from Phase 1 to generate
	a clean csv file with only Luminex data, OMICID and
	DISEASE for each patient.
	-> input file is data/clinical_i2b2trans_1.txt
	-> output file is data/Luminex_phase_I_raw_data.csv
	-> Convert NA values for DISEASE into Control IF patient
	   is marked as Control in diagnosis\\ARM variable.
	"""

	case_index = -1
	omicid_index = -1
	disease_index = -1
	luminex_index = []

	## Get the index of variable to keep
	input_data_file = open("data/clinical_i2b2trans_1.txt", "r")
	cmpt = 0
	for line in input_data_file:
		line = line.split("\n")
		line = line[0]
		line_in_array = line.split("\t")
		if(cmpt == 0):			
			index = 0
			for variable in line_in_array:
				variable_in_array = variable.split("\\")
				if("Luminex" in variable_in_array):
					luminex_index.append(index)
				elif("OMICID" in variable_in_array):
					omicid_index = index
				elif("DISEASE" in variable_in_array):
					disease_index = index
				elif("ARM" in variable_in_array):
					case_index = index
				index += 1
		cmpt += 1
	input_data_file.close()


	## Generate a new file with only
	## the variables we want.
	input_data_file = open("data/clinical_i2b2trans_1.txt", "r")
	output_data_file = open("data/Luminex_phase_I_raw_data.csv", "w")
	cmpt = 0
	for line in input_data_file:
		line = line.split("\n")
		line = line[0]
		line_in_array = line.split("\t")

		line_to_write = ""
		index = 0
		for element in line_in_array:
			element_formated = element.replace("\t", "")
			element_formated = element_formated.replace(" ", "")
			if(index in luminex_index):
				line_to_write += str(element_formated) +","
			elif(index == omicid_index):
				line_to_write += str(element_formated) +","
			elif(index == disease_index):
				if(element_formated == "NA"):
					case_status = line_in_array[case_index]
					case_status = case_status.replace("\t", "")
					case_status = case_status.replace(" ", "")
					if(case_status == "Control"):
						element_formated = "Control"
				line_to_write += str(element_formated) +","			
			index +=1

		line_to_write = line_to_write[:-1]
		output_data_file.write(line_to_write+"\n")
	output_data_file.close()
	input_data_file.close()

	## log message
	print "[+] Luminex data extracted"



def run_discretization(data_file_name):
	"""
	Run discretization using 2 R scripts
	-> data_file_name is a string, name of the data file.
	-> final data are written in the data/rg_data_discretized.txt file
	-> generate a few tmp files
	"""

	print "[+] Run discretization"

	## Copy the data file to an input file for the R Script
	shutil.copy(data_file_name, "data/rg_data_to_discretize.txt")

	## Run the First script (re-order data)
	print "[+] Running R script part 1"
	subprocess.call ("C:\\Program Files\\R\\R-3.3.3\\bin\\Rscript.exe --vanilla rg_discretization_part1.R", shell=False)

	## Reformat the data
	print "[+] Reformat the data for discretization"
	input_data = open("data/rg_data_to_discretize_tmp.txt", "r")
	output_data = open("data/rg_data_good_for_discretization.txt", "w")
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

	## Run the second script (perform discretization)
	print "[+] Running R script part 2"
	subprocess.call ("C:\\Program Files\\R\\R-3.3.3\\bin\\Rscript.exe --vanilla rg_discretization_part2.R", shell=False)
	print "[*] Discretization complete"



def run_feature_selection(data_file_name):
	"""
	-> feature selection process using the Boruta
	algorithm
	"""

	print "[+] Run feature Selection"

	## Copy the data file to an input file for the R Script
	shutil.copy(data_file_name, "data/rg_data_to_filter.txt")

	## Run the R Script (Boruta algorithm)
	print "[+] Running The Boruta Algorithm with R"
	subprocess.call ("C:\\Program Files\\R\\R-3.3.3\\bin\\Rscript.exe --vanilla rg_features_selection.R", shell=False)

	print "[*] Features selection complete"



def run_rule_generation(data_file_name):
	"""
	-> The final step, rule generation
	-> rules are stored in data/rg_all_rules.txt
	-> filtered (non redundant) rules ate stored in data/rg_all_rules_filtered.txt
	"""

	print "[+] Run the rule generation process"

	## Copy the data file to an input file for the R Script
	shutil.copy(data_file_name, "data/rg_input_for_rule_generation.txt")

	## Run the R Script (Boruta algorithm)
	print "[+] Running The Rules Generation With R"
	subprocess.call ("C:\\Program Files\\R\\R-3.3.3\\bin\\R.exe CMD BATCH C:\\Users\\NaturalKiller01\\Desktop\\Nathan\\Spellcraft\\SCRIPTS\\rg_rule_generation.R")

	print "[*] Rules generation complete"



### MAIN ###
target = sys.argv[1]
if(target == "flow"):
	## Generation Rules from flow cytometry
	run_discretization("data/flow_data_phase_1.txt")
	run_feature_selection("data/rg_data_discretized.txt")
	run_rule_generation("data/rg_data_filtered.txt")
elif(target == "luminex"):
	## Generation Rules from Luminex Data
	reformat_luminex_raw_data()
	filter_NA_values("data/Luminex_phase_I_raw_data.csv")
	run_discretization("data/Luminex_phase_I_raw_data_filtered.csv")
	run_feature_selection("data/rg_data_discretized.txt")
	run_rule_generation("data/rg_data_filtered.txt")
elif(target == "HLA"):
	## Generation Rules from HLA Data
	reformat_HLA_raw_data()
	run_discretization("data/HLA_phase_I_raw_data.csv")
	run_feature_selection("data/rg_data_discretized.txt")
	run_rule_generation("data/rg_data_filtered.txt")
elif(target == "test"):
	### TEST SPACE ###
	print "[+] Running test"
else:
	print "[!] argument "+str(target)+" is invalid"

print "[*] Program terminated"