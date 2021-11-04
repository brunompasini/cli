#!/bin/bash


# palbum.sh - Everything from the Command Line
# Prof. Xavier Serpaggi

# Bruno MUCHA PASINI
# bruno.muchapasini@etu.emse.fr


# Global Variables


#inputDirectory=$1
#outputDirectory=$2

inputDirectory=$1
outputDirectory=$2
YEARS=""
DAYS=""
function ValidInputDir() {
	if [ -d $inputDirectory ];
	# check if directory exists
	then
		# ne marche quand est dans ssh

		if [ -z "$(find -type f -name '*.jpg')" ];
		 #check if there are pictures
		then
			echo "error in images : no images"
			exit # do I need to put error ?
		fi

	else
		echo "error in input"
		exit # do I need to put error ?
	fi

	# If nothing happens the inptu is good

}


function ValidOutputDir() {
	if [ -d $outputDirectory ];
	then
		echo "already exists, may overwrite images"
	fi
	$(mkdir -p $outputDirectory)

}

function generateDirectories() {

	#allFiles="$(find  -type f -name "/temp/*.jpg")"

	for x in $inputDirectory/*.jpg; do


		#echo $x 


		vari=$(stat -c %y $x)
    	short="${vari:0:10}"
    	year="${short:0:4}"

		YEARS="$YEARS $year"
		# incrementing a string, to iterate over when creating html

		inter="${short:5:6}"
		month="${inter:0:2}"
		day="${short:8:10}"

		# Splitting string to get data to create folder and rename file

		underl="_"
		tire="-"

		#DAYS="$DAYS $year$underl$month$underl$day"
		# incrementing a string, to iterate over when creating html
		
		path="$outputDirectory/$year/$year$underl$month$underl$day"
		$(mkdir -p $path)

		y="$(basename -- $x)"

		name="$year$underl$month$underl$day$tire$y"
		final="$path/$name"
		$(ln -s $x $final)

		# will work on thumbnails now

		thumbName="$name-thumb.jpg"

		$(mkdir -p "$path/.thumbs")
		thumbPath="$path/.thumbs/$thumbName"
		$(convert $x -thumbnail x150  $thumbPath)
	done
	#cd ..
}

function generateHTML(){

	cd $outputDirectory

	touch index.html
	echo "
	<!DOCTYPE html>
	<html>
	<head>
    	<title>Photo Album</title>
	</head>
	<body>
    	<h1>Photo Album</h1>" >> index.html
    

	for d in */; do
		#ref="$outputDirectory/$d"
		str='<p> <a href="'
		str="$str$d\"> "
		str="$str $d </a> </p>"
		echo $str >> index.html
	done

	echo "</body> </html>" >> index.html
	# Main HTML is generated


	for di in */; do
	# for chaque année
		cd $di
		touch index.html
		echo "<!DOCTYPE html>
			  <html>
			  <head>
    		  <title>" >> index.html

		echo "$di" >> index.html

		echo "</title>
				</head>
				<body>
    			<h1>" >> index.html

		echo "$di" >> index.html
		echo "</h1>" >> index.html

		allImgs="$(find -maxdepth 2 -name '*.jpg')"
		#echo $allImgs

		allThumbs="$(find -type f -name '*.jpg')"
		#echo $allThumbs


		for image in $allImgs; do
			
			nom="$(basename -- $image)"
			myThumb="$(find -type f -name "$nom*thumb.jpg")"
			# uses regex to find corresponding thumbnail


			echo "<p> <a href=\"" >> index.html
			echo "$image\">" >> index.html
			echo "<img src=\"" >> index.html
			echo "$myThumb\">" >> index.html


			echo $image >> index.html
			echo "</a> </p>" >> index.html



		done

		echo "</body> </html>" >> index.html


	done

	



}
#ValidInputDir
#ValidOutputDir
generateDirectories
generateHTML