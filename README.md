# canvasquizzeR

This is an R package with tools to convert quizzes from CSV to QTI quiz format (for Canvas upload), QTI to CSV, and QTI to pretty HTML. 

This is a work in progress. So far, all this package does is convert a multiple-choice quiz in a CSV file to a QTI quiz file, which can then be uploaded to Canvas.

# Installation

Install the package from github using the `install_github()` function from the `devtools` package.

```
# Install the devtools package if necessary:
# install.packages("devtools") 

devtools::install_github("murraylax/canvasquizzeR")
```

Installation on Windows may require the `Rtools42` package. See [https://cran.rstudio.com/bin/windows/Rtools/rtools42/rtools.html](https://cran.rstudio.com/bin/windows/Rtools/rtools42/rtools.html)

# Usage

## Quiz data frame

The quiz, possibly given in a CSV file, needs to be loaded into a data frame. Each row is an individual multiple-choice question. There must be 8 columns named as follows:

 - `G`: A description of the question group. You can have multiple questions with an identical question group. These questions will be grouped together and for each student, Canvas will pick a random question from this group. For example, you can have three questions about a single topic, and Canvas will randomly give your students one of the three given questions. Three rows in your data frame will have an identical value in the `G` column that identifies this group.
 
 - `Question`: Text of the stem of the multiple-choice question

 - `A`: An integer that is equal to 1, 2, 3, or 4, identifying which of the following four choices is the correct answer

 - `Choice 1`: Text for answer choice 1

 - `Choice 2`: Text for answer choice 2

 - `Choice 3`: Text for answer choice 3

 - `Choice 4`: Text for answer choice 4

 - `Feedback`: General feedback given to students after they complete the quiz and answers are shown

The `readr::read_csv()` function is a nice tidy way to read in CSV files, which allows spaces in the column names (necessary for `Choice 1`, etc.).

See [https://raw.githubusercontent.com/murraylax/canvasquizzeR/main/examplequiz.csv](https://raw.githubusercontent.com/murraylax/canvasquizzeR/main/examplequiz.csv) for an example quiz file.

```
quiz.df <- readr::read_csv("examplequiz.csv")
```

## Generate a QTI Quiz File

To generate a QTI file from the data frame, you need the following:

 1. Data frame
 
 2. Folder to save the QTI file (there will be a .zip file and an XML file saved to this folder)
 
 3. A descriptive title for the quiz
 
 4. A file name for the .zip file (the .zip file is what should be uploaded to Canvas)
 
The `generateQTI` function generates a QTI quiz file given the above information. 
 
Example:

```
outfolder <- "C:\\Users/username/Documents/CanvasQuizzes/"
quiztitle <- "Finance Quiz"
quizfilename <- "quiz.zip"

generateQTI(quiz.df, outfolder, quiztitle, quizfilename)
```
