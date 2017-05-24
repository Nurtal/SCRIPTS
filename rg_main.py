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





### TEST SPACE ###
test_file = "data/data_discretized.txt"
truc = detect_file_format(test_file)

run_discretization("data/flow_data_phase_1.txt")
run_feature_selection("data/rg_data_discretized.txt")
run_rule_generation("data/rg_data_filtered.txt")