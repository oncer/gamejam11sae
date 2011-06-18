MXMLC = ./fcsh-wrap
#MXMLC = mxmlc
OPTIONS = -debug=true -static-link-runtime-shared-libraries=true\
	  -library-path+=lib/MinimalComps_0_9_9.swc
FLIXEL = src
SRC = src/*.as
MAIN = src/main.as
SWF = bin/Llama.swf

$(SWF) : $(SRC)
	$(MXMLC) $(OPTIONS) -sp $(FLIXEL) -o $(SWF) -- $(MAIN)

clean :
	rm -f $(SWF)
