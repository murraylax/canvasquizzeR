library(tidyverse)
library(readr)

create_longid <- function(size=33) {
  # Create stupid code
  hexcodes <- as.character(as.hexmode(sample(0:15,size-1,replace=TRUE)))
  longid <- paste(c("g",hexcodes),collapse = "") # Start it with g for some reason??
  return(longid)
}

create_questionxml <- function(df, qn, respids) {
  question_str <- read_file("./question.xml")
  question_str <- str_replace(question_str, "#QuestionText", df$Question[qn])

  question_str <- str_replace(question_str, "#Choice1Text", df$`Choice 1`[qn])
  question_str <- str_replace(question_str, "#Choice2Text", df$`Choice 2`[qn])
  question_str <- str_replace(question_str, "#Choice3Text", df$`Choice 3`[qn])
  question_str <- str_replace(question_str, "#Choice4Text", df$`Choice 4`[qn])

  question_respids <- respids[((qn-1)*4+1):(qn*4)]
  question_str <- str_replace_all(question_str, "#respid1", as.character(question_respids[1]))
  question_str <- str_replace_all(question_str, "#respid2", as.character(question_respids[2]))
  question_str <- str_replace_all(question_str, "#respid3", as.character(question_respids[3]))
  question_str <- str_replace_all(question_str, "#respid4", as.character(question_respids[4]))

  correct_response <- as.integer(df$A[qn])
  correct_respid <- question_respids[correct_response]
  question_str <- str_replace(question_str, "#respidcorrect", as.character(correct_respid))

  question_str <- str_replace(question_str, "#GeneralFeedbackText", df$Feedback[qn])

  questionid <- create_longid()
  question_str <- str_replace(question_str, "#IdentityQuestion", questionid)

  return(question_str)
}

create_groupxml <- function(df, groupi, respids) {
  group_str <- read_file("./group.xml")

  # Group ID
  groupid <- create_longid()
  group_str <- str_replace(group_str, "#groupid", groupid)

  # Group Name
  group_str <- str_replace(group_str, "#GroupName", as.character(groupi))

  # Identify rows in df associated with group
  group_questions_rows <- which(df$G==groupi)

  all_qestion_strs <- ""
  for(q in group_questions_rows) {
    question_str <- create_questionxml(df, q, respids)
    all_qestion_strs <- paste(all_qestion_strs, question_str, sep="\n", collapse = "")
  }
  group_str <- str_replace(group_str, "#AllQuestionsText", all_qestion_strs)
  return(group_str)
}

#' Generate QTI quiz file from data frame
#'
#' @description
#' `generateQTI_df` generates a zipped QTI file and saves it in the folder `outfolder`
#' @param df: data.frame where each row is a question. The column names should be the following:
#'   - G: Qu
#'
#'
generateQTI_df <- function(df, outfolder, quiztitle, quizfilename) {
  nrespids <- nrow(df)*4
  respids <- sample(1000:9999, size=nrespids, replace = FALSE) # Create response ids for every response in the quiz

  wholequiz_str <- read_file("./wholequiz.xml")
  all_group_str <- ""
  all_groups <- unique(df$G)
  for(groupi in all_groups) {
    group_str <- create_groupxml(df, groupi, respids)
    all_group_str <- paste(all_group_str, group_str, sep="\n", collapse="")
  }
  wholequiz_str <- str_replace(wholequiz_str, "#AllGroups", all_group_str)

  # Write the Quiz ID
  quizid <- create_longid()
  wholequiz_str <- str_replace(wholequiz_str, "#quizid", quizid)

  # Write the Quiz Title
  wholequiz_str <- str_replace(wholequiz_str, "#QuizTitle", quiztitle)


  outfile <- sprintf("%s/%s.xml", outfolder, quizid)
  write_file(wholequiz_str, file=outfile)

  systemstr <- sprintf("zip -r -j %s%s %s%s.xml", outfolder, quizfilename, outfolder, quizid)
  system(systemstr)
}

