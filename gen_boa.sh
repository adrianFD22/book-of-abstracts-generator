#!/bin/bash

#############################################################
# usage: run in the directory containing the data for the
#        book of abstracts
#
# Description: generates book of abstracts by creating a
# boa.tex file and adding the following tex files:
#   - Each file in "Plenary". Files are preceded
#   by a number indicating order and _ (lower first).
#   Example (1_Jane Doe.tex).
#   (plenary talks)
#
#   - Each directory in "Sessions" represents a day.
#   Each day contains directories representing the
#   parallel sessions of that day. Each session
#   contains the tex files of the talks. Precedence
#   in day is indicated as in plenaries.
#   (each parallel session and the talks it contains)
#
#   - Each file in "Posters". Preceded by a number
#   as plenaries and sessions.
#   (poster session)
#
#   - Each file in "Workshops"
#   (each workshop)
#
#   Finally, adds the scientific and organizing
#   committee, adds a section at top for acknowledgments
#   and compiles it to pdf.
#
#############################################################


#---------------------
#       Functions
#---------------------

trim-number () {
    echo "${1#*_}"
}

clear-ref () {
    echo -n "\setcounter{equation}{0} "
    echo -n "\setcounter{figure}{0}"
    echo
}

add-to-toc () {
    if [ "$1" = "-p" ]; then
        echo -n "\phantomsection "
        set -- "$2" "$3"
    fi
    echo "\addcontentsline{toc}{$1}{$2}"
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


#---------------------
#        Main
#---------------------

IFS=$(echo -e "\n\b")

# Clean
rm -f "boa.tex"

{
# Preamble
echo
print-comment-block "Preamble"
echo "\input{Miscellaneous/preamble.tex}"
echo
echo "\begin{document}"
echo
echo "\input{Miscellaneous/title-page.tex}"
echo "\tableofcontents"
echo "\newpage"
echo
add-to-toc -p part Acknowledgements
echo "\input{Miscellaneous/acknowledgements.tex}"
echo
echo

# Add plenary talks
print-comment-block "Plenary speakers"
echo "\part*{Plenary speakers}"
add-to-toc part "Plenary speakers"
echo "\thispageheader[L]{Plenary speakers}"
#echo "\thispageheader[R]{}"
echo

for curr_plenary in $(ls -1 Plenary); do
    curr_plenary_trim=$(trim-number "$curr_plenary")
    curr_plenary_day=${curr_plenary_trim%_*}

    curr_plenary_name=${curr_plenary_trim%.*}
    curr_plenary_name=${curr_plenary_name#*_}

    echo "% $curr_plenary_name"
    echo "\thispageheader[R]{$curr_plenary_day}"
    echo "\input{Plenary/$curr_plenary}"
    add-to-toc section "$curr_plenary_name"
    echo "\newpage"
    echo
done
echo "\thispageheader[L]{}"
echo "\thispageheader[R]{}"
echo
echo

# Add parallel sessions
print-comment-block "Parallel sessions"
echo "\part*{Parallel sessions}"
add-to-toc part "Parallel sessions"
echo

# Add each day
for curr_day in $(ls -1 Sessions); do
    curr_day_trim=$(trim-number "$curr_day")

    echo "% $curr_day_trim"
    add-to-toc -p section "$curr_day_trim"

    # Add each session
    for curr_session in $(ls -1 "Sessions/$curr_day"); do
        curr_session_trim=$(trim-number "$curr_session")

        echo "\thispageheader[L]{$curr_session_trim}"
        echo "\thispageheader[R]{$curr_day_trim}"
        add-to-toc -p subsection "$curr_session_trim"

        # Add each talk
        for curr_talk in $(ls -1 "Sessions/$curr_day/$curr_session"); do
            echo -n "    "
            clear-ref
            echo "    \input{Sessions/$curr_day/$curr_session/$curr_talk}"
            echo "    \newpage"
            echo
        done
    done
done
echo "\thispageheader[L]{}"
echo "\thispageheader[R]{}"
echo
echo

# Add posters
print-comment-block "Posters"
echo "\part*{Posters}"
add-to-toc part "Posters"
echo "\thispageheader[L]{Posters}"
#echo "\thispageheader[R]{}"
echo
for curr_poster in $(ls -1 Posters); do
    #curr_poster_trim=$(trim-number "$curr_poster")
    curr_poster_day=${curr_poster%%_*}

    echo "\thispageheader[R]{$curr_poster_day}"
    echo "\input{Posters/$curr_poster}"
    echo "\newpage"
    echo
done
echo "\thispageheader[L]{}"
echo "\thispageheader[R]{}"
echo
echo

# Add workshops
print-comment-block "Workshops"
echo "\part*{Workshops}"
add-to-toc part Workshops
echo "\thispageheader[L]{Workshops}"
echo "\thispageheader[R]{}"
echo
for curr_workshop in $(ls -1 Workshops); do
    curr_workshop_trim=$(trim-number "$curr_workshop")
    curr_workshop_day=${curr_workshop_trim%_*}

    curr_workshop_name=${curr_workshop_trim%.*}
    curr_workshop_name=${curr_workshop_name#*_}

    echo "% $curr_workshop_name"
    echo "\thispageheader[R]{$curr_workshop_day}"
    add-to-toc -p section "$curr_workshop_name"
    echo "\input{Workshops/$curr_workshop}"
    echo "\newpage"
    echo
done
echo "\thispageheader[L]{}"
echo "\thispageheader[R]{}"
echo
echo

# Compile committee
print-comment-block "End book"
echo "\thispageheader[L]{Committees}"
echo "\thispageheader[R]{}"
add-to-toc -p part Committees
echo "\input{Miscellaneous/committees.tex}"

echo "\newpage"
echo '\'
echo
echo "\thispageheader[L]{}"
echo "\thispageheader[R]{}"
echo "\cleardoublepage"
echo
echo "\end{document}"
} >> boa.tex

# Compile boa.tex twice for getting the toc. LaTeX is crazy
for _ in seq 2; do
    pdflatex -interaction=nonstopmode -no-shell-escape boa.tex
done

# Clean after compiling
rm -f "boa.aux"
rm -f "boa.log"
rm -f "boa.toc"
rm -f "boa.out"
