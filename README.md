---
title: "canvasquizzeR"
output:
  html_document:
    number_sections: true
author: "James M. Murray, PhD"
date: "August 26, 2022"
---

This is an R package with tools to convert quizzes from CSV to QTI quiz format (for Canvas upload), QTI to CSV, and QTI to pretty HTML. 

This is a work in progress. So far, this package can convert a quiz in a spreadsheet to a QTI .zip file, which can be uploaded to Canvas, or convert a quiz file downloaded from Canvas to a data frame, which can then be exported to a CSV or other spreadsheet format.

# Installation

Install the package from github using the `install_github()` function from the `devtools` package.

```
# Install the devtools package if necessary:
# install.packages("devtools") 

devtools::install_github("murraylax/canvasquizzeR")
```

Installation on Windows may require the `Rtools42` package. See [https://cran.rstudio.com/bin/windows/Rtools/rtools42/rtools.html](https://cran.rstudio.com/bin/windows/Rtools/rtools42/rtools.html)

# Creating a QTI .zip Quiz File from a Spreadsheet

## Quiz data frame

The quiz, possibly given in a CSV file, needs to be loaded into a data frame. Each row is an individual multiple-choice or essay question. This package supports the following columns:

 - `G`: A description of the question group. You can have multiple questions with an identical question group. These questions will be grouped together and for each student, Canvas will pick a random question from this group. For example, you can have three questions about a single topic, and Canvas will randomly give your students one of the three given questions. Three rows in your data frame will have an identical value in the `G` column that identifies this group.
 
 - `Question`: Text of the stem of the multiple-choice question
 
 - `Question Type`: Character string identifying the type of question, should equal either 'MC' for a multiple choice question or 'Essay' for an essay/short-answer question
 
 - `Text Type`: Character string identifying whether the question text is plain text or html, should equal either 'html' or 'plain'

 - `Points`: Number of points for the question

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

## Uploading to Canvas

Navigate to your `outfolder` folder to find your .zip file. To upload this file to Canvas, use your web browser and navigate to your Canvas course. 

 1. On the *right-side* menu, select the `Import Existing Content` button.
 
 2. In the `Content Type` dropdown list, select `QTI .zip file`
 
 3. Click the `Choose File` button
 
 4. Select the .zip file from the `outfolder` folder
 
 5. Make sure the `Import existing quizzes as New Quizzes` check box is **not selected**
 
 6. Click `Import`
 
 7. Canvas will take a few seconds or minutes to import the quiz. When this process finishes, go to `Quizzes` on the *left-side* menu and find your quiz. You may edit the settings and questions as you see fit.
 
 
# Creating a Data Frame from QTI .zip Quiz File

## Exporting a Canvas Quiz File

If you have a quiz in Canvas, you can export it to a QTI .zip file as follows:

 1. On the *left-side* menu, select `Settings`
 
 2. On the *right-side* menu, select `Export Course Content`
 
 3. Choose the radio button for `Export Type` `Quiz`
 
 4. Select a check box for only one quiz
 
 5. Click the `Create Export` button
 
 6. When the export is finished, there will be a link above with the export. Use the link to download the .zip file. When you save the file, be aware of the folder and filename of the file. You will need this information later.
 
## Creating the quiz data frame

Make note of the name and location of the quiz file. Save the text of the folder path and the quiz file name:

```
folder <- "C:\\Users/username/Documents/CanvasQuizzes/"
filename <- "quiz.zip"
```

Create a quiz data frame using the `create_quizdf_zip()` function:

```
quiz.df <- create_quizdf_zip(filename, folder)
```

The result is a tibble (or data frame) where each row is an individual multiple-choice or essay question. This tibble includes the following columns:

 - `G`: A description of the question group. You can have multiple questions with an identical question group. These questions will be grouped together and for each student, Canvas will pick a random question from this group. For example, you can have three questions about a single topic, and Canvas will randomly give your students one of the three given questions. Three rows in your data frame will have an identical value in the `G` column that identifies this group.
 
 - `Question`: Text of the stem of the multiple-choice question
 
 - `Question Type`: Character string identifying the type of question, should equal either 'MC' for a multiple choice question or 'Essay' for an essay/short-answer question
 
 - `Text Type`: Character string identifying whether the question text is plain text or html, should equal either 'html' or 'plain'

 - `Points`: Number of points for the question

 - `A`: An integer that is equal to 1, 2, 3, or 4, identifying which of the following four choices is the correct answer

 - `Choice 1`: Text for answer choice 1

 - `Choice 2`: Text for answer choice 2

 - `Choice 3`: Text for answer choice 3

 - `Choice 4`: Text for answer choice 4

 - `Feedback`: General feedback given to students after they complete the quiz and answers are shown
 
 
## Writing the quiz to a spreadsheet

You can use the `readr::write_csv()` to write the resulting quiz to a .csv file, or `WriteXLS::WriteXLS()` to write to an Excel .xlsx file:
```
# CSV file
readr::write_csv(quiz.df, file = "./quiz.csv")

# Excel file
WriteXLS::WriteXLS(quiz.df, ExcelFileName = "./quiz.xlsx")
```

# Enjoy!
