% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/render_quiz.R
\name{quiz_format}
\alias{quiz_format}
\title{Check formatting and set default values for quiz data frame, df}
\usage{
quiz_format(df)
}
\arguments{
\item{df}{data frame containing a quiz, hopefully mostly conforming to the above.}
}
\value{
Quiz data frame with the columns above
}
\description{
This function adjusts the format of the quiz to conform to the following:
\itemize{
\item G: Question group
\item Question: Text of the question
\item Question type: Either MC or Essay, for multiple-choice or short-answer. The default is based on whether there is an answer given in column \code{A}, 'MC' if there is, 'Essay' otherwise.
\item Text Type: The type of text in all text columns, 'html' or 'plain', for html-formatted text or plain text. The default is 'html'.
\item Points: Numeric, number of points for the problem. The default is 1.
\item A: Correct answer for a multiple choice question, a number 1 thru 4. Default is NA.
\item 'Choice 1': Choice 1, default is empty character string ""
\item 'Choice 2': Choice 2, default is empty character string ""
\item 'Choice 3': Choice 3, default is empty character string ""
\item 'Choice 4': Choice 4, default is empty character string ""
\item Feedback: General feedback given to students after they complete the quiz and answers are shown. Default is empty character string "".
}

The only required column of the input data frame is \code{Question}. Any other missing columns will be created with default values
}
