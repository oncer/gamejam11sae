MXMLC = ./fcsh-wrap
OPTIONS = -debug=true -static-link-runtime-shared-libraries=true
FLIXEL = src
NAME = llama
SRC = src/main.as\
      src/StartState.as\
      src/IngameState.as\
      src/Llama.as\
      src/WrapSprite.as
MAIN = src/main.as
SWF = Llama.swf

$(SWF) : $(SRC)
	$(MXMLC) $(OPTIONS) -sp $(FLIXEL) -o $(SWF) -- $(MAIN)

clean :
	rm -f $(SWF)
