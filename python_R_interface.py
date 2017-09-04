"""
A few ad hoc function to deal with crazy stuff 
"""


def glmnet_get_selected_features(console_output_file):
	"""
	-> use a txt file, the console output of R script,
	   and select the variables among the sparse matrix
	   where coef != 0, i.e used in the linear model.
	   Such features are considered relevant for the classification.
	-> Process the output of glmnet_feature_selection.R script
	-> return the list of relevant features
	"""

	list_of_selected_features = []
	input_data = open(console_output_file, "r")
	for line in input_data:
		line = line.replace("\n", "")
		line_in_array = line.split("      ") # Please don't ask why ...
		pop_has_null_coefficient = True
		if(len(line_in_array) == 2):
			feature = line_in_array[0]
			try:
				test = float(line_in_array[1])
				if(test != 0):
					pop_has_null_coefficient = False
			except:
				pop_has_null_coefficient = True
			
			if(not pop_has_null_coefficient and feature not in list_of_selected_features):
				list_of_selected_features.append(feature)
	input_data.close()

	return list_of_selected_features
