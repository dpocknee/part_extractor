# part_extractor
A method for the automated extraction of instrumental parts from handwritten musical scores.  From 2012.
This method is designed for the easy, automated extraction of instrumental parts from handwritten scores.
The process works by taking the scanned images of pages of your scores, copying the area containing a particular instrument from every page of your score into new files, and then compiling it into an OpenOffice word file.

This method uses two, free, open source programs, available for both mac and PC:
- The GIMP image editing program. This method definitely works with version 2.6.8. and up
- The 'Writer' word processor from the Open Office office suite. Available from Open Office. This method definitely works with version 3.0.0. in 2012.

This process utilises two scripts:
1. A script for GIMP which extracts the parts into separate files.
2. A script for OpenOffice which compiles them.

The pdf gives full instructions for installation.

Video Tutorial
The video at 
https://www.youtube.com/watch?v=II1VefK2e8k&feature=youtu.be 
shows how the scripts can be used once they are installed and what they can do. I use an example of a 20 page score for 5 instruments on A4 paper in landscape orientation and extract a violin part into a new OpenOffice document in A4 Portrait orientation.  All files for the score are kept in the folder 'Score' on the Desktop. I extract the violin part from this score using GIMP, which saves all images in a new folder named 'Violin Part' on the Desktop. Then OpenOffice is used to compile all the images together into a part in A4 Portrait orientation.


