MXMLC = ./fcsh-wrap
OPTIONS = -debug=true -static-link-runtime-shared-libraries=true
FLIXEL = .
NAME = llama
SRC = main.as\
      StartState.as\
      IngameState.as\
      Llama.as\
      WrapSprite.as
MAIN = main.as
SWF = ../bin/llama.swf

$(SWF) : $(SRC)
	$(MXMLC) $(OPTIONS) -sp $(FLIXEL) -o $(SWF) -- $(MAIN)

clean :
	rm -f $(SWF)
