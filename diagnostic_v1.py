"""
Quick filtering based
on procedure for clinical diagnostic
Focus on RA for now
"""




#-----------#
# Load data #
#-----------#

cohorte = []
articulation_index = -1
anti_cpp_index = -1
RF_index = -1
CRP_index = -1
patient_id_index = -1
disease_index = -1

input_file_name = "data/clinical_data_phase_1.csv"
data = open(input_file_name, "r")
cmpt = 0
for line in data:

	patient = {}

	line = line.split("\n")
	line = line[0]
	line_in_array = line.split(",")

	if(cmpt == 0):
		index = 0
		for var in line_in_array:
			if(var == "\\Clinical\\Symptom\\ABNORMINFLAM"):
				articulation_index = index
			if(var == "\\Autoantibody\\CCP2CALL"):
				anti_cpp_index = index
			if(var == "\\Autoantibody\\RFCALL"):
				RF_index = index
			if(var == "\\Luminex\\CRP"):
				CRP_index = index
			if(var == "\\Clinical\\Diagnosis\\DISEASE"):
				disease_index = index
			if(var == "\\Clinical\\Sampling\\OMICID"):
				patient_id_index = index
			index +=1
	else:
		patient["articulation"] = line_in_array[articulation_index]
		patient["anti_cpp"] = line_in_array[anti_cpp_index]
		patient["RF"] = line_in_array[RF_index]
		patient["CRP"] = line_in_array[CRP_index]
		patient["Disease"] = line_in_array[disease_index]
		patient["ID"] = line_in_array[patient_id_index]
		cohorte.append(patient)
	cmpt += 1
data.close()


#--------------------#
# Perform Diagnostic #
#--------------------#
good_diagnostic = 0
wrong_diagnostic = 0
for patient in cohorte:
	
	articulation = 0
	anti_cpp = 0
	RF = 0
	CRP = 0

	if(patient["articulation"] == "Present"):
		articulation = 1
	if(patient["anti_cpp"] == "positive"):
		anti_cpp = 1
	if(patient["RF"] == "positive"):
		RF = 1
	if(patient["CRP"] == "Yes"):
		CRP = 1

	# Bazinga
	# - actually just making up stuff, if
	#   the score is above a threshold consider
	#   the patient as RA
	
	real_diagnostic = patient["Disease"]
	score = articulation + anti_cpp + RF + CRP
	if(score >= 1):
		if(real_diagnostic == "RA"):
			good_diagnostic += 1
		else:
			wrong_diagnostic += 1


#---------------------#
# Compute Final Score #		
#---------------------#

number_of_patient = len(cohorte)
final_score = (float(good_diagnostic) / float(number_of_patient))*float(100)
error_score = (float(wrong_diagnostic) / float(number_of_patient))*float(100)
print "=> Final Score is "+str(final_score)
print "=> Error score is "+str(error_score)

