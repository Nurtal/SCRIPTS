#
# This script perform a mca on clinical data
# except medication variable and control patients (for now)
# use the acm_clinical.R script.
# Create .tex reports
#




### REFORMAT INPUT FILES ###
"""
-> Convert stupid tsv files into clean csv files
-> Create a file with only the "Clinical" variables 
   (and no medication variable)
"""
index_to_keep = []
medication_index = []

data = open("data/clinical_i2b2trans_1.txt", "r")
output = open("data/clinical_i2b2trans_1.csv", "w")
output_clinical = open("data/clinical_data_phase_1.csv", "w")

cmpt = 0
for line in data:
	line = line.split("\n")
	line = line[0]
	line_in_array = line.split("\t")

	if(cmpt == 0):
		index = 0
		header_in_string = ""
		clinical_header_in_string = ""
		for element in line_in_array:
			header_in_string += str(element)+","
			element_in_array = element.split("\\")
			if("Clinical" in element_in_array or "Autoantibody" in element_in_array):
				index_to_keep.append(index)
				clinical_header_in_string += str(element)+","
			index += 1

		header_in_string = header_in_string[:-1]
		header_in_string = header_in_string.replace(" ", "")
		output.write(header_in_string+"\n")

		clinical_header_in_string = clinical_header_in_string[:-1]
		clinical_header_in_string = clinical_header_in_string.replace(" ", "")
		output_clinical.write(clinical_header_in_string+"\n")

	else:
		index = 0
		line_in_string = ""
		clinical_line_in_string = ""
		for element in line_in_array:
			line_in_string += str(element)+","
			if(index in index_to_keep):
				clinical_line_in_string += str(element)+","
			index += 1

		line_in_string = line_in_string[:-1]
		line_in_string = line_in_string.replace(" ", "")
		output.write(line_in_string+"\n")

		clinical_line_in_string = clinical_line_in_string[:-1]
		clinical_line_in_string = clinical_line_in_string.replace(" ", "")
		output_clinical.write(clinical_line_in_string+"\n")

	cmpt += 1

output_clinical.close()
output.close()
data.close()


### RUN R SCRIPT ###
"""
-> load reformated data
-> perform mca
-> create figures
"""
import os
os.system("Rscript acm_clinical.R")


### CREATE TEX FILES ###
"""
-> create a tex file for each subset of data
"""
sub_data_list = ["lung", "kidney", "nerveSystem", "skin", "muscleAndSkeletal", "comorbidity", "vascular", "gastro", "heart", "diagnosis", "autoantibody"]

for data in sub_data_list:

	data_file_name = "latex\\"+str(data)+"_report.tex"

	report_file = open(data_file_name, "w")

	report_file.write("\\documentclass[a4paper,9pt]{extarticle}\n")
	report_file.write("\\usepackage[utf8]{inputenc}\n")
	report_file.write("\\usepackage[T1]{fontenc}\n")
	report_file.write("\\usepackage{graphicx}\n")
	report_file.write("\\usepackage{xcolor}\n")
	report_file.write("\\usepackage{tikz}\n")
	report_file.write("\\usepackage{pgfplots}\n")
	report_file.write("\\usepackage{amsmath,amssymb,textcomp}\n")
	report_file.write("\\everymath{\displaystyle}\n\n")

	report_file.write("\\usepackage{times}\n")
	report_file.write("\\renewcommand\\familydefault{\\sfdefault}\n")
	report_file.write("\\usepackage{tgheros}\n")
	report_file.write("\\usepackage[defaultmono,scale=0.85]{droidmono}\n\n")

	report_file.write("\\usepackage{multicol}\n")
	report_file.write("\\setlength{\\columnseprule}{0pt}\n")
	report_file.write("\\setlength{\\columnsep}{20.0pt}\n\n")

	report_file.write("\\usepackage{geometry}\n")
	report_file.write("\\geometry{\n")
	report_file.write("a4paper,\n")
	report_file.write("total={210mm,297mm},\n")
	report_file.write("left=10mm,right=10mm,top=10mm,bottom=15mm}\n\n")

	report_file.write("\\linespread{1.30}\n\n")

	report_file.write("\\makeatletter\n")
	report_file.write("\\renewcommand*{\\maketitle}{%\n")
	report_file.write("\\noindent\n")
	report_file.write("\\begin{minipage}{0.4\\textwidth}\n")
	report_file.write("\\begin{tikzpicture}\n")
	report_file.write("\\node[rectangle,rounded corners=6pt,inner sep=10pt,fill=blue!50!black,text width= 0.75\\textwidth] {\\color{white}\\Huge \\@title};\n")
	report_file.write("\\end{tikzpicture}\n")
	report_file.write("\\end{minipage}\n")
	report_file.write("\\hfill\n")
	report_file.write("\\begin{minipage}{0.55\\textwidth}\n")
	report_file.write("\\begin{tikzpicture}\n")
	report_file.write("\\node[rectangle,rounded corners=3pt,inner sep=10pt,draw=blue!50!black,text width= 0.95\\textwidth] {\\LARGE \\@author};\n")
	report_file.write("\\end{tikzpicture}\n")
	report_file.write("\\end{minipage}\n")
	report_file.write("\\bigskip\\bigskip\n")
	report_file.write("}%\n")
	report_file.write("\\makeatother\n\n")

	report_file.write("\\usepackage[explicit]{titlesec}\n")
	report_file.write("\\newcommand*\\sectionlabel{}\n")
	report_file.write("\\titleformat{\\section}\n")
	report_file.write("\t{\\gdef\\sectionlabel{}\n")
	report_file.write("\t\\normalfont\\sffamily\\Large\\bfseries\\scshape}\n")
	report_file.write("\t{\\gdef\\sectionlabel{\\thesection\\ }}{0pt}\n")
	report_file.write("\t{\n")
	report_file.write("\\noindent\n")
	report_file.write("\\begin{tikzpicture}\n")
	report_file.write("\\node[rectangle,rounded corners=3pt,inner sep=4pt,fill=blue!50!black,text width= 0.95\\columnwidth] {\\color{white}\\sectionlabel#1};\n")
	report_file.write("\\end{tikzpicture}\n")
	report_file.write("\t}\n")
	report_file.write("\\titlespacing*{\\section}{0pt}{15pt}{10pt}\n\n")

	report_file.write("\\usepackage{fancyhdr}\n")
	report_file.write("\\makeatletter\n")
	report_file.write("\\pagestyle{fancy}\n")
	report_file.write("\\fancyhead{}\n")
	report_file.write("\\fancyfoot[C]{\\footnotesize \\textcopyright\\ \\@date\\ \\ \\@author}\n")
	report_file.write("\\renewcommand{\\headrulewidth}{0pt}\n")
	report_file.write("\\renewcommand{\\footrulewidth}{0pt}\n")
	report_file.write("\\makeatother\\title{"+str(data)+" dataset}\n")
	report_file.write("\\author{ACM exploration}\n")
	report_file.write("\\date{2017}\n")
	report_file.write("\\begin{document}\n")
	report_file.write("\\maketitle\n\n\n")

	report_file.write("\\section{Overview - Dimmensions}\n\n")

	report_file.write("\\begin{center}\n")
	report_file.write("\\begin{tabular}{c c}\n")
	report_file.write("\t\\includegraphics[scale=0.35]{\"IMAGES/explain_variance_"+str(data)+"\"} & \\includegraphics[scale=0.35]{\"IMAGES/variable_contribution_"+str(data)+"\"} \\\\ \n")
	report_file.write("\tExplained variability & Variables conributions \\\\ \n")
	report_file.write("\\end{tabular}{}\n")
	report_file.write("\\end{center}\n\n")

	report_file.write("\\section{Overview - individuals}\n\n")

	report_file.write("\\begin{center}\n")
	report_file.write("\\begin{tabular}{c c}\n")
	report_file.write("\t\\includegraphics[scale=0.35]{\"IMAGES/individuals_disease_"+str(data)+"\"} & \\includegraphics[scale=0.35]{\"IMAGES/individuals_sex_"+str(data)+"\"} \\\\ \n")
	report_file.write("\tGrouped by disease & Grouped by sex \\\\ \n")
	report_file.write("\\end{tabular}{}\n\n")

	report_file.write("\\begin{tabular}{c}\n")
	report_file.write("\t\\includegraphics[scale=0.35]{\"IMAGES/individuals_center_"+str(data)+"\"}  \\\\ \n")
	report_file.write("Grouped by center  \\\\ \n")
	report_file.write("\\end{tabular}{} \n\n")

	report_file.write("\\end{center}\n")
	report_file.write("\\end{document}\n")


	report_file.close()
