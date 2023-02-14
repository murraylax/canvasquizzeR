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

render_pdf_quiz <- function(quiz.df, outfile, outfolder, quiz_title, quiz_subtitle="", instructor="", includeanswers=TRUE, version="a", seed=1) {

  outfile_pdf <- sprintf("%s.pdf", outfile)

  markdown_file <- sprintf("%s/quiz-generate.Rmd", path.package("canvasquizzeR"))
  rmarkdown::render(markdown_file, outputfile=outfile_pdf, output_dir=outfolder, intermediates_dir=outfolder,
                    params=list(quiz.df=quiz.df, title=quiz_title, subtitle=quiz_subtitle, instructor=instructor, version=version, includeanswers=includeanswers, seed=seed))

}

