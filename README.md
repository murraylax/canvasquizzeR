# canvasquizzeR

This is an R package with tools to convert quizzes given in spreadsheet formats to QTI quiz format (for Canvas upload), QTI to spreadsheets, and (eventually) either format to pretty HTML and/or PDF files. 

This is a work in progress. So far, this package can convert a quiz in a spreadsheet format or word processing format to a QTI .zip file. The QTI .zip file can then be uploaded to Canvas. The package can also convert a quiz QTI .zip file (i.e the file format for quizzes downloaded from Canvas) to a dataframe, which can then be exported to a spreadsheet format.

# Installation

Install the package from github using the `install_github()` function from the `devtools` package.

```
# Install the `devtools` package if necessary:
# install.packages("devtools") 

# Install the package
devtools::install_github("murraylax/canvasquizzeR")
```

Installation on Windows may require the `Rtools42` package. See [https://cran.rstudio.com/bin/windows/Rtools/rtools42/rtools.html](https://cran.rstudio.com/bin/windows/Rtools/rtools42/rtools.html)

# Quiz data frame

A quiz is stores as a dataframe in R. Each rowof the dataframe is an individual multiple-choice or essay question. 

One limitation of this package is that all questions must be strictly text or HTML.  If you want to use images, tables, or other rich content in your quiz questions, the text of the quiz questions, answers, and feedback can be expressed in HTML, but all images and other rich content elements cannot be stored with the quiz object. The HTML can reference externally accessible images.

Quiz dataframes should have some or all of the following columns:

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


# Reading in a Quiz from a Spreadsheet

The package has several frontend functions for reading from different spreadsheet types, including .CSV, Excel .XLSX, and Google spreadsheets.

## Example: Read a .CSV file 

See [https://raw.githubusercontent.com/murraylax/canvasquizzeR/main/examplequiz.csv](https://raw.githubusercontent.com/murraylax/canvasquizzeR/main/examplequiz.csv) for an example quiz .CSV file.

The `readr::read_csv()` function is a nice tidy way to read in CSV files, which allows spaces in the column names (necessary for `Choice 1`, etc.).

```
quiz.df <- readr::read_csv("examplequiz.csv")
```

Alternative, there is a function included in this package called `read_quiz_csv()` that performs a similar function, and returns a quiz dataframe that adheres to the structure described above.

```
quiz.df <- read_quiz_csv("examplequiz.csv")
```

## Example: Read an Excel .XLSX file 

See [https://raw.githubusercontent.com/murraylax/canvasquizzeR/main/examplequiz.xlsx](https://raw.githubusercontent.com/murraylax/canvasquizzeR/main/examplequiz.xlsx) for an example quiz .XLSX file.

The function, `read_quiz_excel()`, takes the filepath of an Excel .xlsx document, and returns a quiz datafrane that adheres to the structure described above.

```
quiz.df <- read_quiz_excel("examplequiz.xlsx")
```

## Example: Read a Google Spreadsheet 

This package provides a front end to the package `googlesheets4` for reading in a quiz from a Google spreadsheet. See [https://docs.google.com/spreadsheets/d/1RId5A2774_EC45u60UKOnbvGOg8x1brraJUFJaacmik](https://docs.google.com/spreadsheets/d/1RId5A2774_EC45u60UKOnbvGOg8x1brraJUFJaacmik) for an example quiz Google spreadsheet.

The function, `read_quiz_googlesheet()`, takes the URL of a Google spreadsheet, and returns a quiz dataframe that adheres to the structure described above.

```
quiz.df <- read_quiz_googlesheet("https://docs.google.com/spreadsheets/d/1RId5A2774_EC45u60UKOnbvGOg8x1brraJUFJaacmik/", noauth=TRUE)
```

* Note that the default value for `noauth` is equal to FALSE. Set equal to TRUE *only if* the Google spreadsheet is accessible to everyone with a link, no Google login authorization is necessary, and you would like to skip authorization.

# Reading in a Quiz from a Word Processing Document

The package can read in a **table** given in a word processing document and convert the information in the table to a quiz data frame.

## Example: Read a table in a Word .DOCX file 

See [https://raw.githubusercontent.com/murraylax/canvasquizzeR/main/examplequiz.docx](https://raw.githubusercontent.com/murraylax/canvasquizzeR/main/examplequiz.docx) for an example quiz .docx file.

The function, `read_quiz_docx()`, takes the filepath of a Word .docx document, and returns a quiz data frame that adheres to the structure described above.

```
quiz.df <- read_quiz_docx("examplequiz.docx")
```

## Example: Read a table in a Google Docs document 

This package provides a front end to the package `googledrive` package (in particular, the `googledrive::drive_download()` function) to download a Google Docs document, read a table, and return a quiz data frame. The function below downloads the Google doc, stores the word processing document locally as a .docx file, and then reads in the .docx file to a quiz data frame. Therefore, the function has the side effect of writing a .docx file in the working directory. 

See [https://docs.google.com/document/d/1R7aiSYbtNroZ4-pZk_gRoFgsthKH-dMQs7xS2jep51Q](https://docs.google.com/document/d/1R7aiSYbtNroZ4-pZk_gRoFgsthKH-dMQs7xS2jep51Q) for an example quiz Google Doc. The following function downloads the file and returns a quiz data frame that adheres to the structure described above.

```
quiz.df <- read_quiz_googledoc("https://docs.google.com/document/d/1R7aiSYbtNroZ4-pZk_gRoFgsthKH-dMQs7xS2jep51Q", noauth=TRUE)
```

* Note that the default value for `noauth` is equal to FALSE. Set equal to TRUE *only if* the Google spreadsheet is accessible to everyone with a link, no Google login authorization is necessary, and you would like to skip authorization.


# Generate a QTI Quiz File

To generate a QTI file from a quiz data frame, you need the following:

 1. Quiz stores in a data frame (see sections above for reading data from spreadsheets and word processing documents into a dataframe)
 
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
