
#' Create an identity for a QTI item.
#'
#' @description
#' Each item in a QTI file contains a unique 33 digit hex code. This function just creates a random 33 character hex code. There are 5.4 duodecillion unique 33-digit hex codes, so it's extremely unlikely two will be the same.
#'
#' @param size Number of digits for the hex code. Defaults to 33.
#' @return Character string of lenghth 34, starting with the letter 'g' and followed by the 33-digit hex code, because that's what Canvas wants?
#' @export
create_longid <- function(size=33) {
  # Create stupid code
  hexcodes <- as.character(as.hexmode(sample(0:15,size-1,replace=TRUE)))
  longid <- paste(c("g",hexcodes),collapse = "") # Start it with g for some reason??
  return(longid)
}

#' Create the XML text for a single multiple-choice question
#'
#' @description
#' Create the XML text for a single multiple-choice question. Takes as an argument a data frame with all the multiple choice questions of the quiz, all the response IDs for every response on the quiz, and an integer identifying which row in the data frame that the question appears.
#' It is necessary to include information for the whole quiz, because each question needs response IDs that are unique to the entire quiz.
#'
#' @param df data.frame where each row is a question. The column names should be the following:
#'   - G: Question group
#'   - Question: Text of the question
#'   - A: Correct answer, a number 1 thru 4
#'   - 'Choice 1': Choice 1
#'   - 'Choice 2': Choice 2
#'   - 'Choice 3': Choice 3
#'   - 'Choice 4': Choice 4
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown
#'
#' @param qn integer identifying the row in `df` that the individual question of interest appears
#' @param respids Vector of unique four-digit integers with length equal to the number of choices in the whole quiz. For example, if there are 10 questions in the quiz and each question has 4 answer choices, `respids` will be a vector of length 10*4 = 40.

#' @return Character string of the XML code for a single multiple-choice quiz question
#' @export
create_questionxml <- function(df, qn, respids) {
  filename <- paste0(path.package("canvasquizzeR"), "/question.xml")

  question_str <- readr::read_file(filename)
  question_str <- stringr::str_replace(question_str, "#QuestionText", df$Question[qn])

  question_str <- stringr::str_replace(question_str, "#Choice1Text", df$`Choice 1`[qn])
  question_str <- stringr::str_replace(question_str, "#Choice2Text", df$`Choice 2`[qn])
  question_str <- stringr::str_replace(question_str, "#Choice3Text", df$`Choice 3`[qn])
  question_str <- stringr::str_replace(question_str, "#Choice4Text", df$`Choice 4`[qn])

  question_respids <- respids[((qn-1)*4+1):(qn*4)]
  question_str <- stringr::str_replace_all(question_str, "#respid1", as.character(question_respids[1]))
  question_str <- stringr::str_replace_all(question_str, "#respid2", as.character(question_respids[2]))
  question_str <- stringr::str_replace_all(question_str, "#respid3", as.character(question_respids[3]))
  question_str <- stringr::str_replace_all(question_str, "#respid4", as.character(question_respids[4]))

  correct_response <- as.integer(df$A[qn])
  correct_respid <- question_respids[correct_response]
  question_str <- stringr::str_replace(question_str, "#respidcorrect", as.character(correct_respid))

  question_str <- stringr::str_replace(question_str, "#GeneralFeedbackText", df$Feedback[qn])

  questionid <- create_longid()
  question_str <- stringr::str_replace(question_str, "#IdentityQuestion", questionid)

  return(question_str)
}

#' Create the XML text for a group of multiple-choice questions
#'
#' @description
#' This function creates the XML code for a group of questions, including the XML creating the group and the XML for each individual question.
#'
#' @param df data.frame where each row is a question. The column names should be the following:
#'   - G: Question group
#'   - Question: Text of the question
#'   - A: Correct answer, a number 1 thru 4
#'   - 'Choice 1': Choice 1
#'   - 'Choice 2': Choice 2
#'   - 'Choice 3': Choice 3
#'   - 'Choice 4': Choice 4
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown
#'
#' @param groupi Character string of the group to create, which must be exactly one of the strings in column 'G' in the data frame `df`
#' @param respids Vector of unique four-digit integers with length equal to the number of choices in the whole quiz. For example, if there are 10 questions in the quiz and each question has 4 answer choices, `respids` will be a vector of length 10*4 = 40.
#'
#' @return Character string of the XML code for a group of multiple-choice quiz questions
#' @export
create_groupxml <- function(df, groupi, respids) {

  filename <- paste0(path.package("canvasquizzeR"), "/group.xml")

  group_str <- readr::read_file(filename)

  # Group ID
  groupid <- create_longid()
  group_str <- stringr::str_replace(group_str, "#groupid", groupid)

  # Group Name
  group_str <- stringr::str_replace(group_str, "#GroupName", as.character(groupi))

  # Identify rows in df associated with group
  group_questions_rows <- which(df$G==groupi)

  all_qestion_strs <- ""
  for(q in group_questions_rows) {
    question_str <- create_questionxml(df, q, respids)
    all_qestion_strs <- paste(all_qestion_strs, question_str, sep="\n", collapse = "")
  }
  group_str <- stringr::str_replace(group_str, "#AllQuestionsText", all_qestion_strs)
  return(group_str)
}

#' Generate QTI quiz file from data frame
#'
#' @description
#' This function generates a zipped QTI file for a multiple-choice test given by the data frame, df, and saves it in the folder `outfolder`
#' @param df This is a data.frame where each row is a question. The column names should be the following:
#'   - G: Question group
#'   - Question: Text of the question
#'   - A: Correct answer, a number 1 thru 4
#'   - 'Choice 1': Choice 1
#'   - 'Choice 2': Choice 2
#'   - 'Choice 3': Choice 3
#'   - 'Choice 4': Choice 4
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown
#' @param outfolder Character string with path to the output folder for the QTI quiz file
#' @param quiztitle Character string with the title for the quiz
#' @param quizfilename Character string with the filename for the quiz
#' @export
generateQTI <- function(df, outfolder, quiztitle, quizfilename) {
  nrespids <- nrow(df)*4
  respids <- sample(1000:9999, size=nrespids, replace = FALSE) # Create response ids for every response in the quiz

  filename <- paste0(path.package("canvasquizzeR"), "/wholequiz.xml")

  wholequiz_str <- readr::read_file(filename)
  all_group_str <- ""
  all_groups <- unique(df$G)
  for(groupi in all_groups) {
    group_str <- create_groupxml(df, groupi, respids)
    all_group_str <- paste(all_group_str, group_str, sep="\n", collapse="")
  }
  wholequiz_str <- stringr::str_replace(wholequiz_str, "#AllGroups", all_group_str)

  # Write the Quiz ID
  quizid <- create_longid()
  wholequiz_str <- stringr::str_replace(wholequiz_str, "#quizid", quizid)

  # Write the Quiz Title
  wholequiz_str <- stringr::str_replace(wholequiz_str, "#QuizTitle", quiztitle)


  outfile <- sprintf("%s/%s.xml", outfolder, quizid)
  readr::write_file(wholequiz_str, file=outfile)

  systemstr <- sprintf("zip -r -j %s%s %s%s.xml", outfolder, quizfilename, outfolder, quizid)
  system(systemstr)
}

