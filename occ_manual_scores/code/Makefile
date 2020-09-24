STATA='/mnt/c/Program Files (x86)/Stata14/StataMP-64.exe'

all: ../output/Teleworkable_BNJDopinion.dta

../output/Teleworkable_BNJDopinion.dta: ../input/Teleworkable_BNJDopinion.csv | ../output
	${STATA} -e load.do
../output:
	mkdir $@
