
# Book of abstracts generator

For organizers of a conference with parallels talks. This repository contains two scripts for compiling the book of abstracts and the correspondent schedule, respectively.

The workflow is as follows: you ask the speakers to send you their abstracts using the given template. When you receive them, you group each file in parallel sessions and you group each parallel session in days. You edit the miscellaneous files as you want, they contain the title page of the book, the acknowledgements... Finally, you run ```./gen_boa.sh``` which generates a tex file together with its compiled pdf file. For compiling a sketch of the schedule, you run ```./gen_parallels.sh``` which also generates tex and pdf. The naming convention for the files of plenary talks, workshops and parallel sessions can be deduced from the example (essentially, an underscore is used as a separator for the name of the plenary speaker, the day when talks and the order to appear).

## Notes
- The scripts uses pdflatex for compiling, but this can be easily changed if needed.
- Even though these scripts use the -no-shell-escape flag, I recommend to check the people's abstracts before compiling them in order to prevent some malicious code to be executed.
- I want to thank Asier López-Gordon for his recommendations for designing this workflow.
