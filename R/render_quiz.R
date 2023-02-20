#' Render a TeX and PDF file of a quiz
#'
#' @description
#' This function takes a dataframe with a quiz and creates Markdown file for the quiz, and renders to TeX and PDF files
#'
#' @param quiz.df data.frame where each row is a question. The column names should be the following:
#'   - G: Question group
#'   - Question: Text of the question
#'   - A: Correct answer, a number 1 thru 4
#'   - 'Choice 1': Choice 1
#'   - 'Choice 2': Choice 2
#'   - 'Choice 3': Choice 3
#'   - 'Choice 4': Choice 4
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown
#'
#' @param outfile String with the name of the output file, but do not include the extension. File names with extensions .md, .tex, and .pdf will be created
#'
#' @param outfolder String with the name of the folder to save the output
#'
#' @param quiz_title String with the title of the quiz
#'
#' @param quiz_subtitle String with a subtitle for the quiz, default is ""
#'
#' @param instructor String with the instructor name, default is ""
#'
#' @param includeanswers Boolean, set equal to TRUE to include answers in the output, FALSE to not include answers in the output. Default value is TRUE.
#'
#' @param version Character, set to "a" or "b" for a version number. If there are more than two questions in any group of questions, for the name random number seed, the two versions will have two different questions. Default value is "a".
#'
#' @export
render_pdf_quiz <- function(quiz.df, outfile, outfolder, quiz_title, quiz_subtitle="", instructor="", includeanswers=TRUE, version="a", seed=1) {

  outfile_pdf <- sprintf("%s.pdf", outfile)

  template_file <- paste0(path.package("canvasquizzeR"), "/rmarkdown/templates/quiz-template.tex")
  template_arg <- c("--template", template_file)

  markdown_file <- sprintf("%s/quiz-generate.Rmd", path.package("canvasquizzeR"))
  rmarkdown::render(markdown_file,
                    output_format = rmarkdown::output_format(knitr=rmarkdown::knitr_options(), pandoc = rmarkdown::pandoc_options(to="pdf", args=template_arg, keep_tex = TRUE)),
                    output_file=outfile_pdf, output_dir=outfolder, intermediates_dir=outfolder, clean=FALSE,
                    params=list(quiz.df=quiz.df, title=quiz_title, subtitle=quiz_subtitle, instructor=instructor, version=version, includeanswers=includeanswers, seed=seed))

}

#' Check formatting and set default values for quiz data frame, df
#'
#' @description This function adjusts the format of the quiz to conform to the following:
#'   - G: Question group
#'   - Question: Text of the question
#'   - Question type: Either MC or Essay, for multiple-choice or short-answer. The default is based on whether there is an answer given in column `A`, 'MC' if there is, 'Essay' otherwise.
#'   - Text Type: The type of text in all text columns, 'html' or 'plain', for html-formatted text or plain text. The default is 'html'.
#'   - Points: Numeric, number of points for the problem. The default is 1.
#'   - A: Correct answer for a multiple choice question, a number 1 thru 4. Default is NA.
#'   - 'Choice 1': Choice 1, default is empty character string ""
#'   - 'Choice 2': Choice 2, default is empty character string ""
#'   - 'Choice 3': Choice 3, default is empty character string ""
#'   - 'Choice 4': Choice 4, default is empty character string ""
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown. Default is empty character string "".
#'
#'   The only required column of the input data frame is `Question`. Any other missing columns will be created with default values
#'
#' @param df data frame containing a quiz, hopefully mostly conforming to the above.
#'
#' @return Quiz data frame with the columns above
#'
#' @export
quiz_format <- function(df) {
  names(df) <- stringr::str_to_title(names(df))

  # Default values
  if(!any(names(df)=="Choice 1")) {
    df$`Choice 1` <- ""
  }
  if(!any(names(df)=="Choice 2")) {
    df$`Choice 2` <- ""
  }
  if(!any(names(df)=="Choice 3")) {
    df$`Choice 3` <- ""
  }
  if(!any(names(df)=="Choice 4")) {
    df$`Choice 4` <- ""
  }
  if(!any(names(df)=="Feedback")) {
    df$`Feedback` <- ""
  }
  if(!any(names(df)=="A")) {
    df$A <- as.numeric(NA)
  }

  if(!any(names(df)=="Question Type")) {
    df$`Question Type` <- ""
  }

  df$A <- as.numeric(df$A)

  df$`Question Type` <- as.character(df$`Question Type`)
  df$`Question Type`[!is.na(df$A)] <- "MC" # Multiple choice if an answer choice is given
  df$`Question Type`[is.na(df$A)] <- "Essay" # Essay if there is no answer choice given

  df$`Choice 1` <- as.character(df$`Choice 1`)
  df$`Choice 2` <- as.character(df$`Choice 2`)
  df$`Choice 3` <- as.character(df$`Choice 3`)
  df$`Choice 4` <- as.character(df$`Choice 4`)
  df$Feedback <- as.character(df$Feedback)

  if(!any(names(df)=="G")) {
    df$G <- paste("Question", as.character(1:nrow(df)))
  }
  df$G <- as.character(df$G)
  if(!any(names(df)=="Points")) {
    df$Points <- 1
  }
  df$Points <- as.numeric(df$Points)
  df$Points[is.na(df$Points)] <- 1

  if(!any(names(df)=="Text Type")) {
    df$`Text Type` <- "html"
  }
  df$`Text Type`[is.na(df$`Text Type`)] <- "html"

  return(df)
}


#' Read a quiz in from a Google Sheet and return a quiz data frame
#'
#' @description This function reads a quiz in from a Google Sheet and return a quiz data frame that conforms to the following:
#'   - G: Question group
#'   - Question: Text of the question
#'   - Question type: Either MC or Essay, for multiple-choice or short-answer. The default is based on whether there is an answer given in column `A`, 'MC' if there is, 'Essay' otherwise.
#'   - Text Type: The type of text in all text columns, 'html' or 'plain', for html-formatted text or plain text. The default is 'html'.
#'   - Points: Numeric, number of points for the problem. The default is 1.
#'   - A: Correct answer for a multiple choice question, a number 1 thru 4. Default is NA.
#'   - 'Choice 1': Choice 1, default is empty character string ""
#'   - 'Choice 2': Choice 2, default is empty character string ""
#'   - 'Choice 3': Choice 3, default is empty character string ""
#'   - 'Choice 4': Choice 4, default is empty character string ""
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown. Default is empty character string "".
#'
#'   The only required column of the input data frame is `Question`. Any other missing columns will be created with default values
#'
#' @param sheet_url URL to a Google Sheet, hopefully mostly conforming to the above.
#'
#' @return Quiz data frame with the columns above
#'
#' @export
read_quiz_googlesheet <- function(sheet_url) {
  df <- googlesheets4::read_sheet(sheet_url)

  df <- quiz_format(df)
  return(df)
}

#' Read a quiz in from a CSV file and return a quiz data frame
#'
#' @description This function reads a quiz in from a CSV file and return a quiz data frame that conforms to the following:
#'   - G: Question group
#'   - Question: Text of the question
#'   - Question type: Either MC or Essay, for multiple-choice or short-answer. The default is based on whether there is an answer given in column `A`, 'MC' if there is, 'Essay' otherwise.
#'   - Text Type: The type of text in all text columns, 'html' or 'plain', for html-formatted text or plain text. The default is 'html'.
#'   - Points: Numeric, number of points for the problem. The default is 1.
#'   - A: Correct answer for a multiple choice question, a number 1 thru 4. Default is NA.
#'   - 'Choice 1': Choice 1, default is empty character string ""
#'   - 'Choice 2': Choice 2, default is empty character string ""
#'   - 'Choice 3': Choice 3, default is empty character string ""
#'   - 'Choice 4': Choice 4, default is empty character string ""
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown. Default is empty character string "".
#'
#'   The only required column of the input data frame is `Question`. Any other missing columns will be created with default values
#'
#' @param filepath Path to the CSV file, hopefully mostly conforming to the above.
#'
#' @return Quiz data frame with the columns above
#'
#' @export
read_quiz_csv <- function(filepath) {
  df <- readr::read_csv(filepath)

  df <- quiz_format(df)
  return(df)
}

#' Read a quiz in from an Excel file and return a quiz data frame
#'
#' @description This function reads a quiz in from an Excel file and return a quiz data frame that conforms to the following:
#'   - G: Question group
#'   - Question: Text of the question
#'   - Question type: Either MC or Essay, for multiple-choice or short-answer. The default is based on whether there is an answer given in column `A`, 'MC' if there is, 'Essay' otherwise.
#'   - Text Type: The type of text in all text columns, 'html' or 'plain', for html-formatted text or plain text. The default is 'html'.
#'   - Points: Numeric, number of points for the problem. The default is 1.
#'   - A: Correct answer for a multiple choice question, a number 1 thru 4. Default is NA.
#'   - 'Choice 1': Choice 1, default is empty character string ""
#'   - 'Choice 2': Choice 2, default is empty character string ""
#'   - 'Choice 3': Choice 3, default is empty character string ""
#'   - 'Choice 4': Choice 4, default is empty character string ""
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown. Default is empty character string "".
#'
#'   The only required column of the input data frame is `Question`. Any other missing columns will be created with default values
#'
#' @param filepath Path to the Excel file, hopefully mostly conforming to the above.
#'
#' @return Quiz data frame with the columns above
#'
#' @export
read_quiz_excel <- function(filepath) {
  df <- readxl::read_excel(filepath)

  df <- quiz_format(df)
  return(df)
}

#' Read a quiz in from a Word file and return a quiz data frame.
#'
#' @description This function reads a quiz in from a Word file. The quiz must be in a table in the document. The functions returns a quiz data frame that conforms to the following:
#'   - G: Question group
#'   - Question: Text of the question
#'   - Question type: Either MC or Essay, for multiple-choice or short-answer. The default is based on whether there is an answer given in column `A`, 'MC' if there is, 'Essay' otherwise.
#'   - Text Type: The type of text in all text columns, 'html' or 'plain', for html-formatted text or plain text. The default is 'html'.
#'   - Points: Numeric, number of points for the problem. The default is 1.
#'   - A: Correct answer for a multiple choice question, a number 1 thru 4. Default is NA.
#'   - 'Choice 1': Choice 1, default is empty character string ""
#'   - 'Choice 2': Choice 2, default is empty character string ""
#'   - 'Choice 3': Choice 3, default is empty character string ""
#'   - 'Choice 4': Choice 4, default is empty character string ""
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown. Default is empty character string "".
#'
#'   The only required column of the input data frame is `Question`. Any other missing columns will be created with default values
#'
#' @param filepath Path to the Word file, with a table hopefully mostly conforming to the above.
#'
#' @param tbl_number If there is more than one table in the file, specify the table number you would like to import. Default is 1.
#'
#' @return Quiz data frame with the columns above
#'
#' @export
read_quiz_docx <- function(filepath, tbl_number=1) {
  doc <- docxtractr::read_docx(filepath)
  df <- docxtractr::docx_extract_tbl(doc,tbl_number)
  names(df) <- stringr::str_replace_all(names(df), "\\.", " ")
  df <- quiz_format(df)
  return(df)
}

#' Read a quiz in from a Google Docs file and return a quiz data frame.
#'
#' @description This function reads a quiz in from a Google Docs file. The quiz must be in a table in the document. The function has the side effect of saving the Google Doc as a Word .docx file. The functions returns a quiz data frame that conforms to the following:
#'   - G: Question group
#'   - Question: Text of the question
#'   - Question type: Either MC or Essay, for multiple-choice or short-answer. The default is based on whether there is an answer given in column `A`, 'MC' if there is, 'Essay' otherwise.
#'   - Text Type: The type of text in all text columns, 'html' or 'plain', for html-formatted text or plain text. The default is 'html'.
#'   - Points: Numeric, number of points for the problem. The default is 1.
#'   - A: Correct answer for a multiple choice question, a number 1 thru 4. Default is NA.
#'   - 'Choice 1': Choice 1, default is empty character string ""
#'   - 'Choice 2': Choice 2, default is empty character string ""
#'   - 'Choice 3': Choice 3, default is empty character string ""
#'   - 'Choice 4': Choice 4, default is empty character string ""
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown. Default is empty character string "".
#'
#'   The only required column of the input data frame is `Question`. Any other missing columns will be created with default values
#'
#'   The function will also save a .docx version of the Google Doc in the default file path.
#'
#' @param doc_url Path to the Google Docs file, with a table hopefully mostly conforming to the above.
#'
#' @param tbl_number If there is more than one table in the file, specify the table number you would like to import. Default is 1.
#'
#' @param overwrite The function has the side effect of saving the Google Doc as a Word .docx file. If the .docx file already exists, set to TRUE or FALSE to overwrite the .docx file. The default is equal to TRUE.
#'
#' @return Quiz data frame with the columns above
#'
#' @export
read_quiz_googledoc <- function(doc_url, tbl_number=1, overwrite=TRUE) {
  metafile <- googledrive::drive_download(doc_url, overwrite=overwrite)
  filepath <- metafile$local_path[1]
  df <- read_quiz_docx(filepath, tbl_number)
  return(df)
}


