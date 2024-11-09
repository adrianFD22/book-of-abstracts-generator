#!/bin/bash


#############################################################
# usage: run in the directory containing the data for the
#        book of abstracts
#############################################################

# Algorithm
# - Add preamble
# - FOR each day in Sessions
#   - Open table environment
#   - Add header indicating the day
#   - FOR each subject in day
#       - Add header with the room and the subject
#       - FOR each talk in subject
#           - Add row indicating the name and the title of the talk
#   - Page break if needed
# - Close table environment


#---------------------
#       Functions
#---------------------

trim-number () {
    echo "${1#*_}"
}


print-comment-block () {
    block_size=25
    n_spaces=$(((block_size - ${#1})/2))

    echo -n "%"
    printf '%%%.0s' $(seq $block_size)
    echo

    echo -n "%"
    printf ' %.0s' $(seq $n_spaces)
    echo "$1"

    echo -n "%"
    printf '%%%.0s' $(seq $block_size)
    echo
}


# https://www.sciencetronics.com/greenphotons/wp-content/uploads/2016/10/xcolor_names.pdf

# Colors are cyclic. If colors1 or colors2 have more than one, then will cycle through them.
# For instance, if colors1 = (orange, blue), the first session will be displayed in orange, the
# second one in blue, the third in orange...

# The colors to use in the session names
colors1=(
    tiafc2
)

# The colors to use for each talk
colors2=(
    tiafc3
)


#---------------------
#        Main
#---------------------

colors_len=${#colors1[@]}
curr_color=0

IFS=$(echo -e "\n\b")

# Clean
rm -f "parallels.tex"

{


column1=0.06
column2=0.15
column3=0.18
mixed_column=$(python -c "print($column2 + $column3)")  # Using python for adding two floating point numbers

# Preamble
echo
print-comment-block "Preamble"
echo "\documentclass[a3paper, landscape]{article}"
echo "\usepackage{mathptmx}\pagestyle{empty}"
echo "\usepackage{geometry}"
echo "\geometry{top = 3cm,"
echo "right = 2cm,"
echo "bottom = 3cm,"
echo "left = 2cm}"
echo
echo "\usepackage{standalone}"          # For including documents ignoring the preamble
echo "\usepackage[table, svgnames, dvipsnames, x11names]{xcolor}"
echo "\usepackage{multirow, multicol}"
echo "\renewcommand{\arraystretch}{2}"
#echo "\setlength\columnsep{1pt}"
echo "\usepackage{makecell}"
echo "\usepackage[T1]{fontenc}"
echo "\usepackage[utf8]{inputenc}"
echo "\usepackage{mathtools, amssymb, latexsym, tikz}"
echo "\usepackage{environ}"             # For redefining thebibliography
echo "\NewEnviron{ignore}{}{}"

# Define colors
echo "\definecolor{tiafc1}{HTML}{004be5}"
echo "\definecolor{tiafc2}{HTML}{5e8be8}"
echo "\definecolor{tiafc3}{HTML}{9aafda}"

# Redefine commands of the abstract template to store the author and the title
# https://tex.stackexchange.com/questions/395851/store-values-text-commands-in-variables
echo "\newcommand\abstracttitle[1]{\gdef\currtitle{#1}}"
echo "\newcommand\firstauthor[2]{\gdef\currauthor{#1}}"
echo "\newcommand{\otherauthor}[2]{}"                                       # Set to empty
echo "\newcommand{\abstracttext}[1]{}"                                      # Set to empty
echo "\renewenvironment{thebibliography}{\ignore}{\endignore}"     # Set to empty
echo
echo "\begin{document}"

room=1  # For printing Room 1, Room 2...

# Add a table for each day
is_odd_table=true     # Maybe there is a more elegant way of doing this thing

echo "\begin{multicols}{2}"
for curr_day in $(ls -1 Sessions); do
    curr_day_trim=$(trim-number "$curr_day")

    echo
    echo
    print-comment-block "$curr_day_trim"
    echo "\begin{tabular}{ | p{${column1}\textwidth} | p{${column2}\textwidth} | p{${column3}\textwidth} | }"
    echo -n "    "
    echo "\hline"
    echo

    echo -n "    "
    echo "\rowcolor{tiafc1}"
    echo -n "    "
    echo "\multicolumn{3}{|c|}{\color{white}\LARGE\textbf{$curr_day_trim}} \\\\ \hline"

    # Add some rows for each session
    for curr_session in $(ls -1 "Sessions/$curr_day"); do
        curr_session_trim=$(trim-number "$curr_session")

        echo
        echo -n "    "
        echo "% ---------------------------------------------------------"

        echo -n "    "
        echo "\rowcolor{${colors1[$curr_color]}}"

        echo -n "    "
        echo "Room $room & \multicolumn{2}{l|}{\Large\textbf{$curr_session_trim}} \\\\ \hline"
        room=$((room+1))

        # Add each talk in a row
        for curr_talk in $(ls -1 "Sessions/$curr_day/$curr_session"); do
            echo -n "    "
            echo "\input{Sessions/$curr_day/$curr_session/$curr_talk}" # \endgroup # This works by closing the thebibliography environment that is not being closed

            echo -n "    "
            echo "\rowcolor{${colors2[$curr_color]}}"

            echo -n "    "
            echo "\gape{0:00} & \currauthor & \currtitle \\\\ \hline"

        done
        curr_color=$(( (curr_color + 1) % colors_len ))
    done

    echo "\end{tabular}"
    echo
    #echo "\vspace{1cm}"

    if [ "$is_odd_table" = true ]; then
        echo "\columnbreak"
        is_odd_table=false
    else
        echo "\pagebreak"
        is_odd_table=true
    fi;
    curr_color=0
done

echo "\end{multicols}"
echo
echo "\end{document}"
} >> parallels.tex

# Compile parallels.tex
pdflatex -interaction=nonstopmode -no-shell-escape parallels.tex

# Clean after compiling
rm -f "parallels.aux"
rm -f "parallels.log"
rm -f "parallels.out"
