"""
Patrice Script
"""
import glob
import numpy

# get files
data_files = glob.glob("*.csv")
result_file = open("patrice_results.csv", "w")

# open file
for data in data_files:
	input_data = open(data, "r")

	x_vector = []
	y_vector = []
	first_range_vector = []

	cmpt = 0
	for line in input_data:
		line = line.split("\n")
		line = line[0]
		line_in_array = line.split(",")

		if(cmpt > 0):
			x = line_in_array[1]
			y = line_in_array[2]

			if(float(x) < 30.0):
				first_range_vector.append(float(y))

			x_vector.append(float(x))
			y_vector.append(float(y))

		cmpt += 1

	# compute measures
	max_y = max(y_vector)
	mean_first_range = numpy.mean(first_range_vector)
	derivative = numpy.gradient(y_vector)
	max_gradient = max(derivative)
	min_gradient = min(derivative)
	line_to_write = str(data)+","+str(max_y)+","+str(mean_first_range)+","+str(max_gradient)+","+str(min_gradient)+"\n"
	result_file.write(line_to_write) 
	
	input_data.close()
result_file.close()