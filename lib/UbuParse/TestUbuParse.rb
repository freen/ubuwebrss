require_relative '../ubu_parse'

UbuParser = UbuParse.new
UbuParser.extract
p UbuParser.extract
UbuParser.getAllURLs
UbuParser.getAllURLs