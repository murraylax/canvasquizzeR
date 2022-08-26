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

is_str_empty <- function(s) {
  if(is.na(s)) return(TRUE)
  if(is.null(s)) return(TRUE)
  if(!is.character(s)) return(TRUE)
  if(stringr::str_squish(s)=="") return(TRUE)
  return(FALSE)
}

str_simplify <- function(s) {
  return(stringr::str_squish( stringr::str_to_lower(s)))
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
#' @param respids Vector of unique four-digit integers with length equal to the number of choices in the whole quiz. For example, if there are 10 multilpe-choice questions in the quiz and each question has 4 answer choices, `respids` will be a vector of length 10*4 = 40.

#' @return Character string of the XML code for a single multiple-choice quiz question
#' @export
create_questionxml_mc <- function(df, qn, respids) {
  # Get all the columns given in df
  quizcols <- colnames(df)

  questionfile <- "/question_mc.xml"

  # Get the XML code for the given question type
  filename <- paste0(path.package("canvasquizzeR"), questionfile)
  question_str <- readr::read_file(filename)

  # Question ID - 33-digit hex code
  questionid <- create_longid()
  question_str <- stringr::str_replace_all(question_str, "#IdentityQuestion", questionid)

  if(magrittr::is_in("Points", quizcols) & !is_str_empty(df$Points[qn])) {
    pts <- as.character(df$Points[qn])
  } else {
    pts <- "1"
  }
  question_str <- stringr::str_replace(question_str, "#pts", pts) # Defaults to 1 if field is not given

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

  # Text type
  if(magrittr::is_in("Text Type", quizcols) & !is_str_empty(df$`Text Type`[qn])) {
    if(df$`Text Type`[qn]=="html") {
      question_str <- stringr::str_replace_all(question_str, "#TextType", "text/html")
    } else if(df$`Text Type`[qn]=="plain") {
      question_str <- stringr::str_replace_all(question_str, "#TextType", "text/plain")
    } else {
      error_str <- sprintf("ERROR: Invalid text type, %s", df$`Text Type`[qn])
      stop(error_str)
    }
  } else {
    question_str <- stringr::str_replace_all(questionstr, "#TextType", "text/plain") # text/plain is the default if not specified
  }

  return(question_str)
}

#' Create the XML text for a single essage question
#'
#' @description
#' Create the XML text for a single essay question. Takes as an argument a data frame with all the questions of the quiz and an integer identifying which row in the data frame that the question appears.
#' It is necessary to include information for the whole quiz, because some questions may need response IDs that are unique to the entire quiz.
#'
#' @param df data.frame where each row is a question. The column names should include the following:
#'   - G: Question group
#'   - Question: Text of the question
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown
#'
#' @param qn integer identifying the row in `df` that the individual question of interest appears
#'
#' @return Character string of the XML code for a single multiple-choice quiz question
#' @export
create_questionxml_essay <- function(df, qn) {
  # Get all the columns given in df
  quizcols <- colnames(df)

  questionfile <- "/question_essay.xml"

  # Get the XML code for the given question type
  filename <- paste0(path.package("canvasquizzeR"), questionfile)
  question_str <- readr::read_file(filename)

  # Question ID - 33-digit hex code
  questionid <- create_longid()
  question_str <- stringr::str_replace_all(question_str, "#IdentityQuestion", questionid)

  if(magrittr::is_in("Points", quizcols) & !is_str_empty(df$Points[qn])) {
    pts <- as.character(df$Points[qn])
  } else {
    pts <- "1"
  }
  question_str <- stringr::str_replace(question_str, "#pts", pts) # Defaults to 1 if field is not given
  question_str <- stringr::str_replace(question_str, "#QuestionText", df$Question[qn])
  question_str <- stringr::str_replace(question_str, "#GeneralFeedbackText", df$Feedback[qn])

  # Text type
  if(magrittr::is_in("Text Type", quizcols) & !is_str_empty(df$`Text Type`[qn])) {
    if(df$`Text Type`[qn]=="html") {
      question_str <- stringr::str_replace_all(questionstr, "#TextType", "text/html")
    } else if(df$`Text Type`[qn]=="plain") {
      question_str <- stringr::str_replace_all(questionstr, "#TextType", "text/plain")
    } else {
      error_str <- sprintf("ERROR: Invalid text type, %s", df$`Text Type`[qn])
      stop(error_str)
    }
  } else {
    question_str <- stringr::str_replace_all(questionstr, "#TextType", "text/plain") # text/plain is the default if not specified
  }

  return(question_str)
}

#' Create the XML text for a single quiz question
#'
#' @description
#' Create the XML text for a single quiz question. The quiz question may be a multiple-choice question (default if not specified) or essay question. Takes as an argument a data frame with all the multiple choice questions of the quiz, all the response IDs for every response on the quiz, and an integer identifying which row in the data frame that the question appears.
#' It is necessary to include information for the whole quiz, because some questions may need response IDs that are unique to the entire quiz.
#'
#' @param df data.frame where each row is a question. The column names should be the following:
#'   - G: Question group
#'   - 'Question Type': Character string identifying the type of question, should equal either 'MC' for a multiple choice question or 'Essay' for an essay/short-answer question
#'   - 'Text Type': Character string identifying whether the question text is plain text or html, should equal either 'html' or 'plain'
#'   - Points: Number of points for the question
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
  # Get all the columns given in df
  quizcols <- colnames(df)

  # Identify the question type
  if(magrittr::is_in("Question Type", quizcols) & !is_str_empty(df$`Question Type`[qn])) {
    question_type <- df$`Question Type`[qn]
  } else {
    question_type <- "MC"
  }
  if(str_simplify(question_type)=="mc") {
    question_str <- create_questionxml_mc(df, qn, respids)
  } else if(str_simplify(question_type)=="essay") {
    question_str <- create_questionxml_essay(df, qn)
  } else {
    errorstr <- sprintf("ERROR: Unknown question type, %s.", question_type)
    stop(errorstr)
  }
  return(question_str)
}


#' Create the XML text for a group of quiz questions
#'
#' @description
#' This function creates the XML code for a group of questions, including the XML creating the group and the XML for each individual question.
#'
#' @param df data.frame where each row is a question. The column names should be the following:
#'   - G: Question group
#'   - 'Question Type': Character string identifying the type of question, should equal either 'MC' for a multiple choice question or 'Essay' for an essay/short-answer question
#'   - 'Text Type': Character string identifying whether the question text is plain text or html, should equal either 'html' or 'plain'
#'   - Points: Number of points for the question
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
#'
#' @param df This is a tibble (i.e. data.frame) where each row is a question. The column names should be the following:
#'   - G: Question group
#'   - 'Question Type': Character string identifying the type of question, should equal either 'MC' for a multiple choice question or 'Essay' for an essay/short-answer question
#'   - 'Text Type': Character string identifying whether the question text is plain text or html, should equal either 'html' or 'plain'
#'   - Points: Number of points for the question
#'   - Question: Text of the question
#'   - A: Correct answer, a number 1 thru 4
#'   - 'Choice 1': Choice 1
#'   - 'Choice 2': Choice 2
#'   - 'Choice 3': Choice 3
#'   - 'Choice 4': Choice 4
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown
#'
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

#' Unzip the QTI file and return the filepath for the XML file containing the assessment
#'
#' @description
#' This function unzips the QTI .zip file that is in `folder`, extracting the contents to the same folder, and returns the filepath for the XML file that contains the quiz questions
#'
#' @param filename Character string of the filename for the .zip file. Do not include the folder/path
#' @param folder Character string of the folder for the .zip file. The contents of the zip file will be extracted to the same folder.
#'
#' @return Character string of the filepath to the XML file containing the assessment tag (i.e. the XML file with the quiz questions)
#' @export
extract_qtizip <- function(filename, folder) {
  lastchar <- stringr::str_sub(folder, -1)
  if(lastchar != "/") {
    folder <- sprintf("%s/", folder)
  }
  filepath <- sprintf("%s%s", folder, filename)
  allfiles <- utils::unzip(filepath, list=TRUE)

  utils::unzip(zipfile=filepath, exdir=folder)

  xmlfiles <- dplyr::filter(allfiles, stringr::str_detect(Name, ".xml"))
  assessment.file <- ""
  for(i in 1:nrow(xmlfiles)) {
    xml_filepath <- sprintf("%s%s", folder, xmlfiles$Name[i])
    xmlroot <- XML::xmlRoot( XML::xmlParse(xml_filepath) )

    assessmemt.xml <- XML::xmlElementsByTagName(xmlroot, "assessment")
    if(length(assessmemt.xml)>0) {
      assessment.file <- xml_filepath
    }
  }
  return(assessment.file)
}

#' Return a quiz tibble
#'
#' @description
#' Return an empty tibble with the columns associated with quiz data frames used in this package
#'
#' @param nrows Number of rows for the tibble. Default is 0.
#'
#' @return Returns a tibble (i.e. data.frame) where each row can hold a quiz question. The column names are those that are used in this package for quizzes
#'   - G: Question group
#'   - 'Question Type': Character string identifying the type of question, should equal either 'MC' for a multiple choice question or 'Essay' for an essay/short-answer question
#'   - 'Text Type': Character string identifying whether the question text is plain text or html, should equal either 'html' or 'plain'
#'   - Points: Number of points for the question
#'   - Question: Text of the question
#'   - A: Correct answer, a number 1 thru 4
#'   - 'Choice 1': Choice 1
#'   - 'Choice 2': Choice 2
#'   - 'Choice 3': Choice 3
#'   - 'Choice 4': Choice 4
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown
#' @export
quiz_tibble <- function(nrows=0) {
  df <- tibble::tibble(`G`=as.character(NA),
                       `Question Type`=as.character(NA),
                       `Text Type`=as.character(NA),
                       `Points`=as.numeric(NA),
                       `Question`=as.character(NA),
                       `A`=as.character(NA),
                       `Choice 1`=as.character(NA),
                       `Choice 2`=as.character(NA),
                       `Choice 3`=as.character(NA),
                       `Choice 4`=as.character(NA),
                       `Feedback`=as.character(NA),
                       .rows=nrows)

  return(df)
}



#' Extract information for a single quiz question from XML
#'
#' @description
#' Extract information for a single quiz question from an XML node and return in a single-row tibble
#'
#' @param question.xml The XMLNode object associated with a quiz question
#'
#' @return Returns a single-row tibble with the following columns:
#'   - G: Question group
#'   - 'Question Type': Character string identifying the type of question, should equal either 'MC' for a multiple choice question or 'Essay' for an essay/short-answer question
#'   - 'Text Type': Character string identifying whether the question text is plain text or html, should equal either 'html' or 'plain'
#'   - Points: Number of points for the question
#'   - Question: Text of the question
#'   - A: Correct answer, a number 1 thru 4
#'   - 'Choice 1': Choice 1
#'   - 'Choice 2': Choice 2
#'   - 'Choice 3': Choice 3
#'   - 'Choice 4': Choice 4
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown
#' @export
extract_question <- function(question.xml) {
  question.df <- quiz_tibble(nrows=1)

  texttype <- XML::xmlGetAttr(question.xml[["presentation"]][["material"]][["mattext"]], "texttype")
  if(texttype=="text/html") question.df$`Text Type`[1] <- "html"
  if(texttype=="text/plain") question.df$`Text Type`[1] <- "plain"

  question_str <- XML::xmlValue(question.xml[["presentation"]][["material"]][[1]][[1]])
  question_str <- stringr::str_squish(question_str)
  question.df$Question[1] <- question_str

  feedback_str <- XML::xmlValue(question.xml[["itemfeedback"]][["flow_mat"]][["material"]][["mattext"]])
  feedback_str <- stringr::str_squish(feedback_str)
  question.df$Feedback[1] <- feedback_str

  questiondata <- question.xml[["itemmetadata"]][["qtimetadata"]]
  nfields <- XML::xmlSize(questiondata)
  for(nf in 1: nfields) {
    fieldlabel <- XML::xmlValue(questiondata[[nf]][["fieldlabel"]])
    if(fieldlabel=="question_type") {
      question_type <- XML::xmlValue(questiondata[[nf]][["fieldentry"]])
      if(question_type=="multiple_choice_question") question.df$`Question Type`[1] <- "MC"
      if(question_type=="essay_question") question.df$`Question Type`[1] <- "Essay"
    }

    if(fieldlabel=="points_possible") {
      pts <- as.numeric( XML::xmlValue(questiondata[[nf]][["fieldentry"]]) )
      question.df$Points <- pts
    }
  }



  if(question_type=="multiple_choice_question") {
    responses.xml <- question.xml[["presentation"]][["response_lid"]][["render_choice"]]
    nresponses <- XML::xmlSize(responses.xml)

    resplabels <- c()

    choice_colidx <- stringr::str_which(names(question.df), "Choice 1")
    for(nr in 1:nresponses) {
      response_str <- XML::xmlValue(responses.xml[[nr]][["material"]][[1]])
      question.df[1,choice_colidx+nr-1] <- response_str

      # Get the response label
      resplabel <- as.numeric(XML::xmlAttrs(responses.xml[[nr]],"ident"))
      resplabels <- c(resplabels, resplabel)
    }

    # Get response label for correct answer
    res <- XML::xmlElementsByTagName( question.xml[["resprocessing"]], "respcondition")
    for(nres in 1:length(res)) {
      resi <- res[nres]$respcondition
      if(XML::xmlGetAttr(resi, "continue")=="No") {
        # This is the correct answer
        correctlabel <- as.numeric(XML::xmlValue(resi[["conditionvar"]][["varequal"]]))
      }
    }
    A <- as.character(which(resplabels==correctlabel))
    question.df$A[1] <- A
  }

  return(question.df)
}

#' Extract information for a group of quiz questions
#'
#' @description
#' Extract information for all the questions in a group of questions from an XML node associated with a question group and return in a single-row tibble
#'
#' @param group.xml The XMLNode object associated with a group of quiz questions
#'
#' @return Returns a tibble with all the questions in the group, where each row is a question, and the tibble has the following columns:
#'   - G: Question group
#'   - 'Question Type': Character string identifying the type of question, should equal either 'MC' for a multiple choice question or 'Essay' for an essay/short-answer question
#'   - 'Text Type': Character string identifying whether the question text is plain text or html, should equal either 'html' or 'plain'
#'   - Points: Number of points for the question
#'   - Question: Text of the question
#'   - A: Correct answer, a number 1 thru 4
#'   - 'Choice 1': Choice 1
#'   - 'Choice 2': Choice 2
#'   - 'Choice 3': Choice 3
#'   - 'Choice 4': Choice 4
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown
#' @export
extract_group_questions <- function(group.xml) {
  group.df <- quiz_tibble()

  nquestions <- XML::xmlSize(group.xml)
  G <- XML::xmlGetAttr(group.xml, "title")

  for(nq in 2:nquestions) { # First element is header stuff for the group
    questioni.xml <- group.xml[[nq]]
    dfi <- extract_question(questioni.xml)
    group.df <- dplyr::bind_rows(group.df, dfi)
  }
  group.df$G <- G
  return(group.df)
}

#' Extract all the questions from a quiz given in an XML file
#'
#' @description
#' Extract all the questions from a quiz given in an XML file and return in a tibble
#'
#' @param xml_filepath Character string equal to the file path for the XML file containing the assessment
#'
#' @return Returns a tibble with all the questions in the group, where each row is a question, and the tibble has the following columns:
#'   - G: Question group
#'   - 'Question Type': Character string identifying the type of question, should equal either 'MC' for a multiple choice question or 'Essay' for an essay/short-answer question
#'   - 'Text Type': Character string identifying whether the question text is plain text or html, should equal either 'html' or 'plain'
#'   - Points: Number of points for the question
#'   - Question: Text of the question
#'   - A: Correct answer, a number 1 thru 4
#'   - 'Choice 1': Choice 1
#'   - 'Choice 2': Choice 2
#'   - 'Choice 3': Choice 3
#'   - 'Choice 4': Choice 4
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown
#' @export
extract_quiz_xml <- function(xml_filepath) {
  df <- quiz_tibble()
  xmlroot <- XML::xmlRoot( XML::xmlParse(xml_filepath) )

  questiongroups <- xmlroot[[1]][[2]]
  ngroups <- XML::xmlSize(questiongroups)

  for(ng in 1:ngroups) {
    groupi.xml <- questiongroups[[ng]]
    dfi <- extract_group_questions(groupi.xml)
    df <- dplyr::bind_rows(df, dfi)
  }
  return(df)
}

#' Extract all the questions from a quiz from a QTI .zip file
#'
#' @description
#' Extract all the questions from a quiz given in a QTI .zip file and return in a tibble
#'
#' @param filename Character string of the filename for the .zip file. Do not include the folder/path
#' @param folder Character string of the folder for the .zip file. The contents of the zip file will be extracted to the same folder.
#'
#' @return Returns a tibble with all the questions in the quiz, where each row is a question, and the tibble has the following columns:
#'   - G: Question group
#'   - 'Question Type': Character string identifying the type of question, should equal either 'MC' for a multiple choice question or 'Essay' for an essay/short-answer question
#'   - 'Text Type': Character string identifying whether the question text is plain text or html, should equal either 'html' or 'plain'
#'   - Points: Number of points for the question
#'   - Question: Text of the question
#'   - A: Correct answer, a number 1 thru 4
#'   - 'Choice 1': Choice 1
#'   - 'Choice 2': Choice 2
#'   - 'Choice 3': Choice 3
#'   - 'Choice 4': Choice 4
#'   - Feedback: General feedback given to students after they complete the quiz and answers are shown
#' @export
create_quizdf_zip <- function(filename, folder) {
  assessment.file <- extract_qtizip(filename, folder)
  quiz.df <- extract_quiz_xml(assessment.file)
  return(quiz.df)
}

