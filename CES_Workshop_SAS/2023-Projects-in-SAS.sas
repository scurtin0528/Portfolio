/************************************************************************************************************************/
/* PROGRAM NAME:  Practical_training_workshop_2023.SAS                													*/
/* LOCATION: P:\Teams\1_Microdata_Users_Workshop\2023_Microdata_Users_Workshop\Workshop Handouts (Code, Guide, etc.)\Sample code\SAS*/
/*                                                                   													*/
/* FUNCTION: SAS CODE FOR WORKSHOP PROJECTS 																			*/
/*                                                                   													*/
/* WRITTEN BY:  	Scott Curtin		                                         										*/
/*                                                                   													*/
/*    SAS version 9.4  			                                      													*/
/*                                                                   													*/
/* MODIFICATIONS:                                                     													*/
/* DATE-      MODIFIED BY-                                            													*/
/* -----      ------------                                            													*/
/* 06/26/18   SALLY REYES    USE 2016 Q1 to Q4 and 2017 Q1 DATA															*/
/*                           UPDATE CODE TO USE NEW SAS PROCEDURES     													*/
/*                           PROC SURVEYMEANS, PROC SURVEYREG, PROC MIANALYZE      										*/
/*                           ALWAYS ANNUALIZE EXPENDITURES AND WEIGHTS        											*/
/*                           DELETE FINCBTXM FROM PROJECTS 1 TO 4       												*/
/*                           CREATE NEW FORMATS                        													*/
/*                           CREATE NEW PROJECT 8 TO GET INCOME MEANS AND STANDARD ERRORS								*/
/*                           REPLACE PROC SUMMARY BY PROC MEANS WHEN CALCULATING MEANS AND STANDARD ERRORS				*/
/* 06/26/18   BRYAN RIGG     ADDED PROJECT 10																			*/
/*                           USES 2020 MIDYEAR PUMD   		   	     													*/
/*                           PROC SURVEYMEANS, PROC SURVEYREG, PROC MIANALYZE      										*/
/*                                                                                                                      */
/* 03/28/23   Aaron Cobet    USES 2021 PUMD  																			*/
/*                           PROC SURVEYMEANS, PROC SURVEYREG, PROC MIANALYZE      										*/
/*                                                                                                                      */
/************************************************************************************************************************/

/*******************************************************************************/
/*******************************************************************************/
/******************** SAS CODE FOR WORKSHOP PROJECTS ***************************/
/*******************************************************************************/
/*******************************************************************************/
  
LIBNAME INI 'C:\2021_CEX\intrvw21'; 
LIBNAME IND 'C:\2021_CEX\diary21';
LIBNAME INE 'C:\2021_CEX\expn21';
LIBNAME INI20 'C:\2020_CEX\intrvw20';
LIBNAME INE20 'C:\2020_CEX\intrvw20\expn20';
LIBNAME INI19 'C:\2019_CEX\intrvw19';

/* ASSIGN REFERENCE NAMES TO LIBRARIES CONTAINING INTERVIEW, DIARY, AND EXPN */
/* DATA FOR TRAINING PROJECTS */
/* Save files on your C drive */

/* CREATE FORMAT FOR THE FAMILY TYPE */
PROC FORMAT ;
VALUE $FAMTYPE    /* FAM_TYPE */
	 '1' = 'Married couple only'
	 '2' = 'Married Couple, own children only, oldest child under 6 years old'
	 '3' = 'Married Couple, own children only, oldest child 6 to 17 years old'
	 '4' = 'Married Couple, own children only, oldest child over 17 years old'
	 '5' = 'All other Married Couple CUs'
	 '6' = 'One parent, male, own children at least one child under 18 years old'
	 '7' = 'One parent, female, own children, at least one child under 18 years old'
	 '8' = 'Single consumers'
	 '9' = 'Other consumer units'
	 ;
RUN;

/* CREATE FORMAT FOR THE NUMBER OF CHILDREN IN THE CU */
PROC FORMAT ;
VALUE CHILDAGE  /* CHILDREN */
	 0 = '0 children'
	 1 = '1 child'
	 2 = '2 children'
	 3 = '3 children'
	 4 = '4 or more children'
	 ;
RUN;

/* CREATE FORMAT FOR THE EDUCATION VARIABLES */
PROC FORMAT ;
VALUE $EDSCHL_A  /*SCHOOL*/
	 '1' = 'College or university'
	 '2' = 'Elementary through high school'
	 '3' = 'Child day care center'
	 '4' = 'Nursery school or preschool'
	 '5' = 'Vocational or technical school'
	 '6' = 'Other school'
     ' ' = 'Not specified'
	 ;

VALUE $EDUC_AY /*EXPTYP*/
	 '100' = 'Recreational lessons'
	 '200' = 'Nursery sch/day care'
	 '300' = 'Tuition'
	 '310' = 'Housing'
	 '320' = 'Food or board'
	 '340' = 'Private school bus'
	 '345' = 'Test prep./tutoring'
	 '355' = 'Books'
	 '358', '360' = 'Other expenses'
     '330' - '335','361'- HIGH  = 'Combined expense'
     '   ' = 'Not specified'*/
	;


VALUE $EDUCGFTC /*IN_OUT*/
 	 '1' = 'Person inside the CU'
	 '2' = 'Person outside the CU'
	  ;
RUN;


/*******************************************************************************/
/********************************* PROJECT 1 ***********************************/
/*******************************************************************************/
/************ CALCULATE ANNUAL EDUCATION EXPENDITURES BY FAMILY TYPE ***********/
/*********************** USING INTERVIEW FMLI FILE *****************************/
/*******************************************************************************/

TITLE1 "PROJECT 1";

/* CREATE DATA SET CONTAINING DATA FOR A COLLECTION YEAR FROM 4 QUARTERLY FMLI FILES */
DATA FMLI (KEEP = NEWID FAM_TYPE FAM_SIZE EDUCA EDUCA_PR);
	SET INI20.FMLI211 INI.FMLI212 INI.FMLI213 INI.FMLI214;

/*CREATE ANNUALIZED QUARTERLY EDUCATION EXPENSE*/
	EDUCA = (EDUCAPQ + EDUCACQ) * 4;  

/* INCLUDE FORMAT FOR FAMILY TYPE */
	FORMAT FAM_TYPE $FAMTYPE.;

/*CREATE EXPENSE REPORTING INDICATOR FOR USE IN PERCENT RERPORTING CALCULATION*/
	IF EDUCA  > 0 THEN EDUCA_PR = 1; 
	ELSE EDUCA_PR = 0;
RUN;

PROC SORT DATA=FMLI;
	BY NEWID;
RUN;

/* PRINT 15 OBSERVATIONS TO PREVIEW DATASET */
PROC PRINT DATA = FMLI (OBS = 15);
	VAR NEWID FAM_TYPE FAM_SIZE EDUCA EDUCA_PR;

/* INCLUDE FORMATS */
	FORMAT EDUCA DOLLAR10.2;

	TITLE2 'STACKED DATA AND CREATED VARIABLES';	
RUN;

/*********************************************/
/* THE DATASET FMLI WILL BE USED IN PROJECT 2 */
/*********************************************/
PROC SORT DATA = FMLI;
	BY FAM_TYPE;
RUN;

/* CALCULATE MEANS, EXPENDITURE STANDARD ERRORS AND PERCENT REPORTING FOR EACH FAMILY TYPE */

PROC MEANS DATA = FMLI NOPRINT N MEAN STDERR;
 	BY FAM_TYPE;
	VAR EDUCA EDUCA_PR FAM_SIZE;
	OUTPUT OUT = Project_1 (DROP = _TYPE_ RENAME = (_FREQ_ = COUNT) )
		  MEAN = EDUCA EDUCA_PR FAM_SIZE
		STDERR = STE;
RUN;

/* PRINT OUTPUT FOR EACH FAMILY TYPE */

PROC PRINT DATA = Project_1 LABEL NOOBS;
	
	VAR COUNT FAM_TYPE FAM_SIZE EDUCA STE EDUCA_PR;

/* INCLUDE FORMATS */
	FORMAT 	EDUCA DOLLAR12.2;
	FORMAT 	STE DOLLAR9.2;
	FORMAT 	COUNT COMMA5.;
	FORMAT  EDUCA_PR PERCENT7.2;

	TITLE2 	"MEANS, STANDARD ERROR, PERCENT REPORTING, AND COUNT FOR CU'S BY FAMILY TYPE";
	LABEL 	FAM_SIZE   = 'Mean Family Size'
			Count 	   = 'Count'
			FAM_TYPE   = 'Family Type (FAM_TYPE)'
			EDUCA	   = 'Education Expenditure Mean'	
			STE		   = 'Education Expenditure Standard Error'
			EDUCA_PR   = 'Education Expenditure Percent Reporting ';
	RUN;


/****************************************************************************/
/******************************* PROJECT 2 **********************************/
/****************************************************************************/
/* CALCULATING ANNUAL EDUCATION EXPENDITURES BY NUMBER OF CHILDREN **********/
/* IN HOUSEHOLD USING INTERVIEW FMLY AND MEMB FILES *************************/
/****************************************************************************/

TITLE1 "PROJECT 2";

/* CREATE A DATA SET CONTAINING A YEAR OF DATA FROM 4 QUARTERLY MEMB FILES **/
DATA MEMI (KEEP = NEWID CU_CODE CHILD); 
	SET INI20.MEMI211 INI.MEMI212 INI.MEMI213 INI.MEMI214;

/* CREATE NEW VARIABLE AGE TO IDENTIFY THE AGE OF THE CHILDREN */
	IF CU_CODE = 3 THEN CHILD = 1;
	ELSE CHILD = 0;
RUN;

/* CREATE SUMMARY IDENTIFIER AT THE HOUSEHOLD LEVEL TO DETERMINE THE NUMBER OF CHILDREN */
PROC SORT DATA = MEMI;
	BY NEWID;
RUN;

/* GET NUMBER OF CHILDREN IN EACH CONSUMER UNIT */
PROC SUMMARY NOPRINT DATA=MEMI;
	BY NEWID;
	VAR CHILD;
	OUTPUT 	OUT  = CHILD_SUM 
            SUM  = CHILDREN;
RUN;

/* COMBINE ALL HOUSEHOLDS WITH MORE THAN 3 CHILDREN INTO ONE GROUP */
DATA CHILD_SUM;
 	SET CHILD_SUM;
 	IF CHILDREN > 3 THEN CHILDREN = 4;
RUN;

/* SORT THE SUMMED MEMBI FILE AND FMLI FILE BY NEWID AND MERGE */
/************************************************/
/* THIS DATASET WILL BE USE LATER IN PROJECT 6  */
/************************************************/
PROC SORT DATA = CHILD_SUM;
	BY NEWID;
RUN;

/************************************************/
/* PROC SORT DATA FMLI BY NEWID FROM PROJECT 1  */
/************************************************/
PROC SORT DATA = FMLI;
	BY NEWID;
RUN;

/* MERGE FAMILY FILE WITH NUMBER OF CHILDREN IN EACH CONSUMER UNIT */
DATA INC_BY_CHILD;
    MERGE CHILD_SUM FMLI;
    BY NEWID;
RUN;  

/* SUMMARIZE THE FILE WITH CHILDREN BY NUMBER OF CHILDREN */
/************************************************/
/* THIS DATASET WILL BE USE LATER IN PROJECT 3  */
/************************************************/
PROC SORT DATA = INC_BY_CHILD;
    BY CHILDREN;
RUN;

/* CALCULATE MEANS, EXPENDITURE STANDARD ERRORS AND PERCENT REPORTING FOR EACH FAMILY TYPE */
PROC MEANS DATA = INC_BY_CHILD NOPRINT N SUM MEAN;
 	BY CHILDREN;
	VAR EDUCA EDUCA_PR FAM_SIZE;
	OUTPUT OUT	= Project_2  (DROP= _TYPE_ RENAME= (_FREQ_ = COUNT) )
		   MEAN	= EDUCA EDUCA_PR FAM_SIZE 
		 STDERR = EDUCA_STE;
RUN;

/* ADD FORMATS AND PRINT RESULTS */

PROC PRINT DATA = Project_2 LABEL NOOBS;
	   VAR COUNT CHILDREN EDUCA EDUCA_STE EDUCA_PR;

/* INCLUDE FORMATS */
	   FORMAT EDUCA EDUCA_STE DOLLAR10.2;
       FORMAT COUNT           COMMA5.;
	   FORMAT CHILDREN        CHILDAGE.;
	   FORMAT EDUCA_PR        PERCENT7.2;

	   TITLE2 "MEANS, STANDARD ERROR, PERCENT REPORTING, AND COUNT FOR CU'S BY NUMBER OF CHILDREN";
	   LABEL 	
			COUNT			= 'Count'
			CHILDREN		= 'Number of Children'
			EDUCA			= 'Education Expenditure Mean'
			EDUCA_STE		= 'Education Expenditure Standard Error'
			EDUCA_PR		= 'Education Expenditure Percent Reporting';
RUN;

/****************************************************************************/
/******************************* PROJECT 3 **********************************/
/****************************************************************************/
/********* CALCULATING ANNUAL EDUCATION EXPENDITURES BY TYPE OF SCHOOL ******/
/****************************************************************************/

TITLE1 "PROJECT 3";

/* CREATE A DATA SET CONTAINING A YEAR OF DATA FROM 4 QUARTERLY MTAB FILES **/

/* CREATE educational VARIABLES BASED ON THE FOLLOWING UCCS:

  1. Tuition: 670110, 670210, 670410, 670901
  2. Test: 670903
  3. Books: 660110, 660210, 660410, 660901, 660902
  4. Other: 670902 (INTERVIEW) 660000 (DIARY)

Tuition 
  College tuition 670110       
  Elementary and high school tuition 670210       
  Vocational and technical school tuition 670410       
  Other schools tuition 670901       

Test
  Test preparation, tutoring services 670903       

BOOKS
  School books, supplies, equipment for college 660110       
  School books, supplies, equipment for elementary, high school 660210 
  School books, supplies, equipment for vocational and technical schools 660410       
  School books, supplies, equipment for day care, nursery 660901 
  School books, supplies, equipment for other schools 660902       

Other
  Other school expenses including rentals 670902 */

DATA MTBI(KEEP = NEWID UCC COST Tuition_COST Test_COST BOOKS_COST OTHER_COST); 
	SET INI20.MTBI211 INI.MTBI212 INI.MTBI213 INI.MTBI214;
 
	COST = COST * 4;  /* ANNUALIZE ALL EXPENDITURES BY MULTIPLYING COST BY 4 */

	IF UCC IN ("670110" "670210" "670410" "670901")
	    THEN Tuition_COST = COST;
	    ELSE Tuition_COST = 0;

	IF UCC IN ("670903")
	    THEN Test_COST = COST;
	    ELSE Test_COST = 0;

	IF UCC IN ("660110" "660210" "660410" "660901" "660902")
		THEN BOOKS_COST = COST;
	    ELSE BOOKS_COST = 0;

	IF UCC IN ("670902")
		THEN OTHER_COST = COST;
	    ELSE OTHER_COST = 0;
RUN;

PROC SORT DATA = MTBI;
	BY NEWID;
RUN;

/* SUM NEWLY CREATED COST VARIABLES */
/*******************************************************************************/
/* THE OUTPUT DATASET EDUCATION_UCC WILL BE USE LATER IN PROJECT 6             */
/*******************************************************************************/
PROC SUMMARY NOPRINT DATA= MTBI;
	BY NEWID;
	VAR Tuition_COST Test_COST Books_COST OTHER_COST;
		OUTPUT 	OUT	= EDUCATION_UCC (DROP= _TYPE_ _FREQ_) 
             	SUM	= Tuition_COST Test_COST Books_COST OTHER_COST;
RUN;

/*******************************************************/
/* PROC SORT DATA INC_BY_CHILD BY NEWID FROM PROJECT 2 */
/*******************************************************/
PROC SORT DATA = INC_BY_CHILD;
	BY NEWID;
RUN;

/*******************************************************************************/
/* MERGE EDUCATION_UCC WITH FULL_FAMILY FILE INC_BY_CHILD CREATED IN PROJECT 2 */
/*******************************************************************************/
/* CREATE DUMMY VARIABLES TO TABULATE PERCENT REPORTING */
/* SUM VARIABLES TO TABULATE PERCENT REPORTING */

DATA EDUCATION;
	MERGE INC_BY_CHILD EDUCATION_UCC;
	BY NEWID;

/* CHANGE MISSINGS TO 0 */
	IF Tuition_COST = . THEN Tuition_COST = 0;
	IF Test_COST 	= .	THEN Test_COST	  = 0;
	IF Books_COST 	= . THEN Books_COST	  = 0;
	IF OTHER_COST 	= . THEN OTHER_COST   = 0;

/* CREATE PERCENT REPORTING VARIABLES */
	IF Tuition_COST NE 	0 THEN Tuition_PR = 1; 
	ELSE Tuition_PR = 0;

	IF Test_COST NE 0 THEN Test_PR = 1; 
	ELSE Test_PR = 0;

    IF Books_COST NE 0 THEN Books_PR = 1; 
	ELSE Books_PR = 0;

    IF OTHER_COST NE 0 THEN OTHER_PR = 1; 
	ELSE OTHER_PR = 0;
RUN;

/* SORT MERGED FILE BY FAMILY TYPE */
PROC SORT DATA = EDUCATION;
	BY CHILDREN;
RUN;

/* CALCULATE MEANS, PERCENT REPORTING, AND STANDARD ERRORS FOR EACH EDUCATION EXPENSE */
PROC MEANS DATA = EDUCATION NOPRINT N MEAN STDERR;
	BY CHILDREN;
	VAR Tuition_COST Tuition_PR;
	OUTPUT OUT = TUITION (DROP= _TYPE_ RENAME= (_FREQ_ = COUNT) )
	      MEAN = COST P_RPT
	    STDERR = STE;
RUN;

PROC MEANS DATA = EDUCATION NOPRINT N MEAN STDERR;
	BY CHILDREN;
	VAR Test_COST Test_PR;
	OUTPUT OUT = TEST (DROP= _TYPE_ RENAME= (_FREQ_ = COUNT) )
	      MEAN = COST P_RPT 
	    STDERR = STE;
RUN;

PROC MEANS DATA = EDUCATION NOPRINT N MEAN STDERR;
	BY CHILDREN;
	VAR Books_COST Books_PR;
	OUTPUT OUT = BOOKS (DROP= _TYPE_ RENAME= (_FREQ_ = COUNT) )
	      MEAN = COST P_RPT 
		STDERR = STE;
RUN;

PROC MEANS DATA = EDUCATION NOPRINT N MEAN STDERR;
	BY CHILDREN;
	VAR OTHER_COST OTHER_PR;
	OUTPUT OUT = OTHER (DROP= _TYPE_ RENAME= (_FREQ_ = COUNT) )
	      MEAN = COST P_RPT 
	    STDERR = STE;
RUN;

/* CREATE DATASET WITH ALL EXPENDITURE DATA     */
/************************************************/
/* THIS DATASET WILL BE USE LATER IN PROJECT 4  */
/************************************************/
DATA Project_3;
	LENGTH TYPE $10.;
	SET TUITION (IN = A)
		TEST    (IN = B)
		BOOKS   (IN = C)
		OTHER   (IN = D);
	IF A THEN TYPE = "TUITION";
	IF B THEN TYPE = "TEST";
	IF C THEN TYPE = "BOOKS";
	IF D THEN TYPE = "OTHER";

/* INCLUDE FORMATS */
	FORMAT CHILDREN  CHILDAGE.; 
RUN;

/* ADD FORMATS AND PRINT RESULTS */

PROC PRINT DATA = Project_3 LABEL NOOBS;
	VAR COUNT CHILDREN TYPE COST STE P_RPT;
	
/* INCLUDE FORMATS */
	FORMAT COST STE DOLLAR9.2;
	FORMAT P_RPT PERCENT7.1;

	TITLE2 "MEANS, STANDARD ERROR, PERCENT REPORTING, AND COUNT FOR CUS";
	TITLE3 "BY EDUCATION EXPENDITURE TYPE AND NUMBER OF CHILDREN";
		LABEL	Count 	   = 'Count'
				CHILDREN   = 'Number of Children'
				COST 	   = 'Education Expenditure Mean'
				STE	       = 'Education Expenditure Standard Error'
				P_RPT	   = 'Education Expenditure Percent Reporting'
				TYPE 	   = 'Education Expenditure Type';
RUN;

/****************************************************************************/
/******************************* PROJECT 4 **********************************/
/****************************************************************************/
/********* CALCULATING ANNUAL EDUCATION EXPENDITURES BY FAMILY TYPE *********/
/*** USING INTERVIEW FMLY AND MTAB FILES AND DIARY FMLD AND EXPD FILES ******/
/****************************************************************************/

TITLE1 "PROJECT 4";

/* CREATE DEMOGRAPHIC VARIABLE FOR FAMILY TYPE FROM 4 FMLD FILES */
DATA FMLD (KEEP = NEWID FAM_SIZE);
	SET IND.FMLD211 IND.FMLD212 IND.FMLD213 IND.FMLD214;

RUN;

/* SORT THE FAMILY FILE BY NEWID */
PROC SORT DATA = FMLD;
	BY NEWID;
RUN;

DATA MEMD(KEEP = NEWID CU_CODE1 CHILD); 
	SET IND.MEMD211 IND.MEMD212 IND.MEMD213 IND.MEMD214;

/* CREATE NEW VARIABLE AGE TO IDENTIFY THE AGE OF THE CHILDREN */
	IF CU_CODE1 in (3) THEN CHILD = 1;
	ELSE CHILD = 0;
RUN;

/* SORT THE MEMBER FILE BY NEWID */
PROC SORT DATA = MEMD;
	BY NEWID;
RUN;

/* ADD NUMBER OF CHILDREN IN EACH CONSUMER UNIT */
PROC SUMMARY NOPRINT DATA=MEMD;
	BY NEWID;
	VAR CHILD;
		OUTPUT 	OUT = D_CHILD_SUM  (DROP = _TYPE_ RENAME = (_FREQ_ = COUNT) )
             	SUM = CHILDREN;
RUN;

/* COMBINE ALL HOUSEHOLDS WITH MORE THAN 3 CHILDREN INTO ONE GROUP */
DATA D_CHILD_SUM;
 	SET D_CHILD_SUM;
 	IF CHILDREN > 3 THEN CHILDREN = 4;
RUN; 

/* SORT THE SUMMED MEMBD FILE AND FMLD FILE BY NEWID AND MERGE */
PROC SORT DATA = D_CHILD_SUM;
	BY NEWID;
RUN;

/* MERGE FAMILY FILE WITH NUMBER OF CHILDREN IN CONSUMER UNIT */
Data D_INC_BY_CHILD;
    MERGE D_CHILD_SUM FMLD;
    BY NEWID;

/* INCLUDE FORMATS */
	FORMAT CHILDREN  CHILDAGE.;
Run; 

/* CREATE A DATA SET FOR DIARY EDUCATION EXPENDITURES WITH A YEAR OF DATA FROM 4 DIARY EXPD FILES */
/* DIARY EDUCATION ITEMS: school supplies, etc. - unspecified 660000 */
DATA EXPD(KEEP = NEWID UCC DIARY_EDU COST);
	SET IND.EXPD211 IND.EXPD212 IND.EXPD213 IND.EXPD214;

	COST = COST * 52;   /* ANNUALIZE DIARY EXPENDITURES BY MULTIPLYING COST BY 52 */

	IF UCC IN ('660000') THEN DIARY_EDU = COST; 
	ELSE DIARY_EDU = 0;
RUN;

/* SORT THE EXPENDITURE FILE BY NEWID */
PROC SORT DATA = EXPD;
	BY NEWID;
RUN;

/* SUM NEWLY CREATED COST VARIABLE BY CONSUMER UNIT */
PROC SUMMARY NOPRINT DATA=EXPD;
	BY NEWID;
	VAR DIARY_EDU;
		OUTPUT 	OUT = DIARY_EDU (DROP=_FREQ_ _TYPE_) 
             	SUM = DIARY_EDU_SUM;
RUN;

/* MERGE FMLD FILE WITH EDUCATION DATASET CREATED ABOVE BY NEWID */
DATA DIARY_EDU_SUM;
	MERGE DIARY_EDU D_INC_BY_CHILD;
	BY NEWID;

	    IF DIARY_EDU_SUM = . THEN DIARY_EDU_SUM = 0;

		IF DIARY_EDU_SUM NE 0 THEN SUP_PR = 1;
		ELSE SUP_PR = 0;
RUN;

PROC SORT DATA = DIARY_EDU_SUM;
    BY CHILDREN;
run; 

/* CALCULATE MEANS USING DIARY EDUCATION DATA SET FOR EACH FAMILY TYPE */
PROC MEANS DATA = DIARY_EDU_SUM NOPRINT N MEAN STDERR;
	BY CHILDREN;
	VAR DIARY_EDU_SUM SUP_PR;
	OUTPUT	OUT	= DIARY_EDU_EXP  (DROP= _TYPE_ RENAME= (_FREQ_ = COUNT) ) 
           MEAN = COST P_RPT
		 STDERR = STE;
RUN;

DATA DIARY_EDU_EXP;
	SET DIARY_EDU_EXP; 
	   TYPE = 'SUPPLIES';
	RUN;

/***********************************************************************************/
/* GET EDUCATION EXPENSES FROM INTERVIEW FILE FROM PROJECT 3 RESULTS DATASET       */
/* MERGE DIARY EDUCATION EXPENSES WITH INTERVIEW EXPENDITURES FROM PROJECT 3 FILES */
/***********************************************************************************/
DATA Project_4;
    SET Project_3 DIARY_EDU_EXP;
RUN;

PROC SORT DATA = PROJECT_4; 
BY CHILDREN; 
RUN;

/* ADD FORMATS AND PRINT RESULTS */

PROC PRINT DATA = PROJECT_4 LABEL NOOBS;

VAR COUNT CHILDREN TYPE COST STE P_RPT;
SUM COST;
BY CHILDREN;	

/* INCLUDE FORMATS */
	FORMAT COST STE DOLLAR9.2;
	FORMAT P_RPT PERCENT7.1;
	FORMAT CHILDREN  CHILDAGE.;

	TITLE2 "MEANS, STANDARD ERROR, PERCENT REPORTING, AND COUNT FOR CUS BY EDUCATION EXPENDITURE TYPE";
	LABEL	Count 	   = 'Count'
			CHILDREN   = 'Number of Children'
			COST 	   = 'Education Expenditure Mean'
			STE	       = 'Education Expenditure Standard Error'
			P_RPT	   = 'Education Expenditure Percent Reporting'
			TYPE 	   = 'Education Expenditure Type';
			
		RUN;

/************************************************************************************/
/*********************************** PROJECT 5 **************************************/
/************************************************************************************/
/** CALCULATE STATISTICS FOR NON-EXPENDITURE CHARACTERISTICS BY SCHOOL OR FACILITY **/
/**************** EDUCATION EXPENDITURES USING INTERVIEW EDA FILES ******************/
/************************************************************************************/

TITLE1 "PROJECT 5";

/*CREATE A DATA SET CONTAINING EDUCATION EXPENSES FROM 2021 INTERVIEWS FROM INTERVIEW EDA FILE*/

 /**  List of school types for the variable: EDSCHL_A
    1 "College or university" 
    2 "Elementary through high school" 
    3 "Child day care center"
    4 "Nursery school or preschool"
    5 "Vocational or technical school"
    6 "Other school";    **/

DATA PROJECT_5 (KEEP = NEWID EDSCHL_A SCHOOL EDUCGFTC IN_OUT QYEAR EDUC_AY EXPTYP);
  SET INE.EDA21;

/* INCLUDE FORMATS */
  FORMAT SCHOOL $EDSCHL_A.;
  FORMAT EXPTYP $EDUC_AY.;
  FORMAT IN_OUT $EDUCGFTC.;

SCHOOL = EDSCHL_A;
EXPTYP = EDUC_AY;
IN_OUT = EDUCGFTC;

IF QYEAR NE "20221";   /* IF QYEAR = "20221" THEN Delete; */
RUN; 

PROC FREQ DATA = PROJECT_5;
	TITLE2 "FREQUENCY COUNT OF EDA EXPENDITURE RECORDS BY SCHOOL TYPE";
  TABLES SCHOOL / OUT=Project_5_A MISSING;
RUN;

PROC FREQ DATA = PROJECT_5;
	TITLE2 "FREQUENCY COUNT OF EDA EXPENDITURE RECORDS BY SCHOOL TYPE AND GIFT STATUS";
  TABLES SCHOOL * IN_OUT / OUT = Project_5_B MISSING;
RUN;

PROC FREQ DATA = PROJECT_5;
	TITLE2 "FREQUENCY COUNT OF EDA EXPENDITURE RECORDS BY EXPENSE CATEGORY AND SCHOOL TYPE";
  TABLES EXPTYP * SCHOOL / OUT = Project_5_C MISSING;
RUN;

/***********************************************************************************/
/**************************** PROJECT 6 ********************************************/
/***********************************************************************************/
/* CALCULATING WEIGHTED ANNUAL MEAN EDUCATION EXPENDITURES                        **/
/* BY Family type OF MEMBERS FROM DATA SET CREATED IN PROJECT 2                  ***/
/* Collection year estimates                                                     ***/
/***********************************************************************************/
/* USE FINLWT21 IN ORDER TO APPROPRIATELY WEIGHT THE DATA FOR POPULATION ESTIMATES */
/***********************************************************************************/

TITLE1 "PROJECT 6";

DATA FMLI;
	SET INI20.FMLI211 INI.FMLI212 INI.FMLI213 INI.FMLI214;
    
	COL_POPWEIGHT = FINLWT21/4;
	RUN; 

/* SORT THE SUMMED MEMI(CHILD_SUM), FMLI, AND THE SUMMED MTBI (EDUCATION_UCC) BY NEWID AND MERGE */
PROC SORT DATA = FMLI; 			
BY NEWID; 
RUN;

/****************************************/
/* CHILD_SUM DATASET FROM PROJECT 2     */
/****************************************/
PROC SORT DATA = CHILD_SUM; 	
BY NEWID; 
RUN;

/* SAME PROCEDURE AS WITH PROJECT 3*/
DATA MTBI( KEEP = NEWID UCC COST Tuition_COST Test_COST BOOKS_COST OTHER_COST); 
      SET INI20.MTBI211 INI.MTBI212 INI.MTBI213 INI.MTBI214;
 
	IF UCC IN ("670110", "670210", "670410", "670901")
	    THEN Tuition_COST = COST;
	    ELSE Tuition_COST = 0;

	IF UCC IN ("670903")
	    THEN Test_COST = COST;
	    ELSE Test_COST = 0;

	IF UCC IN ("660110", "660210", "660410", "660901", "660902")
		THEN BOOKS_COST = COST;
	    ELSE BOOKS_COST = 0;

	IF UCC IN ("670902")
		THEN OTHER_COST = COST;
	    ELSE OTHER_COST = 0;
RUN;

/*SUM NEWLY CREATED COST VARIABLES*/
PROC SORT DATA = MTBI;
	BY NEWID;
RUN;

PROC SUMMARY NOPRINT DATA= MTBI;
	BY NEWID;
	VAR Tuition_COST Test_COST Books_COST OTHER_COST;
		OUTPUT 	OUT	= EDUCATION_UCC (DROP = _TYPE_ _FREQ_) 
             	SUM	= Tuition_COST Test_COST Books_COST OTHER_COST;
RUN;

DATA FMLI_MEMI_MTBI;
    MERGE CHILD_SUM FMLI EDUCATION_UCC;
    BY NEWID;

/* INCLUDE FORMATS */
	FORMAT CHILDREN  CHILDAGE.;

/* CHANGE MISSINGS TO 0 */
	IF Tuition_COST = . THEN Tuition_COST = 0;
	IF Test_COST 	= .	THEN Test_COST	  = 0;
	IF Books_COST 	= . THEN Books_COST	  = 0;
	IF OTHER_COST 	= . THEN OTHER_COST   = 0;

/* CREATE TOTAL EDUCATION EXPENDITURE VARIABLE */
	EDUCA_COST = Tuition_COST + Books_COST + Test_COST + Other_COST;
	EDUCA_COST_WT = EDUCA_COST * FINLWT21;
RUN;  

PROC SORT DATA = FMLI_MEMI_MTBI; 
BY CHILDREN; 
RUN;


/* CREATE AGGREGATE Education AND POPULATION WEIGHTS VARIABLES FOR EACH FAMILY TYPE */
PROC SUMMARY NOPRINT DATA=FMLI_MEMI_MTBI;
	BY CHILDREN;
	VAR EDUCA_COST_WT COL_POPWEIGHT;
	OUTPUT OUT= EDU_SUMMARY (DROP= _TYPE_ RENAME= (_FREQ_ = COUNT) ) 
           SUM= EDUCA_COST_WT COL_POPWEIGHT;
RUN;

Data Project_6(KEEP = COUNT CHILDREN EDUCA_COST_WT COL_EDUCA_COST COL_POPWEIGHT);
SET EDU_SUMMARY; 

/* CALCULATE COLLECTION YEAR MEAN EDUCATION EXPENDITURES */
COL_EDUCA_COST = EDUCA_COST_WT / COL_POPWEIGHT;

RUN; 

PROC PRINT DATA= PROJECT_6 LABEL NOOBS;
   VAR COUNT CHILDREN COL_EDUCA_COST COL_POPWEIGHT;

  /* INCLUDE FORMATS */
   FORMAT COL_EDUCA_COST DOLLAR18.2;
   FORMAT COL_POPWEIGHT COMMA15.;

   TITLE2 "AVERAGE ANNUAL (COLLECTION YEAR) WEIGHTED EDUCATION EXPENDITURE BY NUMBER OF CHILDREN IN THE CU";
   LABEL	CHILDREN 	   = '# of Children'
			COL_EDUCA_COST = 'Average Annual Education Expense'
			COL_POPWEIGHT  = 'Population';
RUN; 

/***************************************************************************/
/***************************************************************************/
/******************************* PROJECT 7 *********************************/
/***************************************************************************/
/**** CALCULATING CALENDAR YEAR EDUCATION EXPENDITURES BY # Children *******/
/******* GROUP USING INTERVIEW FMLY FILES **********************************/
/***************************************************************************/
/***************************************************************************/
/********* CALCULATE WEIGHTED CALENDAR MEANS  ******************************/
/***************************************************************************/

TITLE1 "PROJECT 7";

/* CREATE DATA SET CONTAINING A CALENDAR YEAR OF DATA FROM 5 QUARTERLY FMLY FILES */

DATA FMLI (KEEP = NEWID FINLWT21 QINTRVYR MONTH CAL_POPWEIGHT);
      SET INI.FMLI212 INI.FMLI213 INI.FMLI214 INI.FMLI221 INI20.FMLI211;

/* SELECT ONLY THOSE OBSERVATIONS IN THE CALENDAR YEAR REFERENCE PERIOD 2019 */
/* BECAUSE SOME EXPENDITURES REPORTED IN 2019Q1 OCCURRED IN 2018 AND SOME EXPENDITURES REPORTED */
/* IN 2020Q1 OCCURRED IN 2019 */
	   
/* CREATED NUMERIC MONTH VARIABLE TO CALCULATE THE DENOMINATOR WEIGHTS */
	MONTH = INPUT(QINTRVMO,3.);

/* TOTAL POPULATION FOR THE DENOMINATOR */
/* Adjust weights for calendar year estimates to reflect number of month of reference period. */
/* THAT CU COULD REPORT EXPENDITURES THAT OCCURRED IN CALENDAR YEAR */
	IF QINTRVYR = '2021' THEN DO;
		IF MONTH IN (1, 2, 3) THEN CAL_POPWEIGHT = FINLWT21 * (((MONTH - 1) / 3) / 4);	/* FIRST QUARTER */
		ELSE CAL_POPWEIGHT = FINLWT21 / 4;												/* QUARTERS 2, 3, 4 */
	END;
	IF QINTRVYR = '2022' THEN CAL_POPWEIGHT = FINLWT21 * (((4 - MONTH) / 3) / 4);		/* LAST QUARTER */

RUN; 

PROC SORT DATA = FMLI; 			
BY NEWID; 
RUN;

/****************************************************************************************************/
/* SAME PROCEDURE AS WITH PROJECT 2 BUT READING 5 QUARTERS OF DATA */
/* CREATE A DATA SET CONTAINING A YEAR OF DATA FROM 5 QUARTERLY MEMB FILES */

DATA MEMI (KEEP = NEWID CU_CODE CHILD); 
	SET INI20.MEMI211 INI.MEMI212 INI.MEMI213 INI.MEMI214 INI.MEMI221;
    

/* CREATE NEW VARIABLE AGE TO IDENTIFY THE AGE OF THE CHILDREN */
	IF CU_CODE = 3 THEN CHILD = 1;
	ELSE CHILD = 0;
RUN;

/* CREATE SUMMARY IDENTIFIER AT THE HOUSEHOLD LEVEL TO DETERMINE THE NUMBER OF CHILDREN */
PROC SORT DATA = MEMI;
	BY NEWID;
RUN;

/* GET NUMBER OF CHILDREN IN EACH CONSUMER UNIT */
PROC SUMMARY NOPRINT DATA=MEMI;
	BY NEWID;
	VAR CHILD;
	OUTPUT 	OUT  = CHILD_SUM 
            SUM  = CHILDREN;
RUN;

/* COMBINE ALL HOUSEHOLDS WITH MORE THAN 3 CHILDREN INTO ONE GROUP */
DATA CHILD_SUM;
 	SET CHILD_SUM;
 	IF CHILDREN > 3 THEN CHILDREN = 4;
RUN;; 

PROC SORT DATA = CHILD_SUM;
	BY NEWID;
RUN;

/****************************************************************************************************/
/* SAME PROCEDURE AS WITH PROJECT 3 BUT READING 5 QUARTERS OF DATA */
DATA MTBI( KEEP = NEWID UCC COST Tuition_COST Test_COST BOOKS_COST OTHER_COST); 
	SET INI.MTBI212 INI.MTBI213 INI.MTBI214 INI.MTBI221 INI20.MTBI211;

	IF UCC IN ("670110", "670210", "670410", "670901")
	    THEN Tuition_COST = COST;
	    ELSE Tuition_COST = 0;

	IF UCC IN ("670903")
	    THEN Test_COST = COST;
	    ELSE Test_COST = 0;

	IF UCC IN ("660110", "660210", "660410", "660901", "660902")
		THEN BOOKS_COST = COST;
	    ELSE BOOKS_COST = 0;

	IF UCC IN ("670902")
		THEN OTHER_COST = COST;
	    ELSE OTHER_COST = 0;

	IF REF_YR = "2021";   /* SUBSET FOR EXPENDITURES IN THE CALENDAR YEAR 2019 */
RUN;

/*SUM NEWLY CREATED COST VARIABLES*/
PROC SORT DATA = MTBI;
	BY NEWID;
RUN;

PROC SUMMARY NOPRINT DATA= MTBI;
	BY NEWID;
	VAR Tuition_COST Test_COST Books_COST OTHER_COST;
		OUTPUT 	OUT	= EDUCATION_UCC (DROP = _TYPE_ _FREQ_) 
             	SUM	= Tuition_COST Test_COST Books_COST OTHER_COST;
RUN;

/****************************************************************************************************/
/* MERGE ALL THREE DATASETS BY NEWID */
DATA FMLI_MEMI_MTBI;
    MERGE 	CHILD_SUM (IN = A) 
			FMLI (IN = B)
			EDUCATION_UCC (IN = C);
    BY NEWID;

  /* INCLUDE FORMATS */
   FORMAT CHILDREN  CHILDAGE.;
 
		EDUCA_COST = TUITION_COST + BOOKS_COST + TEST_COST + OTHER_COST;
		EDUCA_COST_WT = EDUCA_COST * FINLWT21; 

RUN;  

PROC SORT DATA = FMLI_MEMI_MTBI;
BY CHILDREN; 
RUN;

/* CREATE AGGREGATE Education AND POPULATION WEIGHTS VARIABLES FOR EACH FAMILY TYPE */
PROC SUMMARY NOPRINT DATA=FMLI_MEMI_MTBI;
	BY CHILDREN;
	VAR EDUCA_COST_WT CAL_POPWEIGHT;
	OUTPUT OUT= EDU_SUMMARY (DROP= _TYPE_ RENAME= (_FREQ_ = COUNT) ) 
           SUM= EDUCA_COST_WT CAL_POPWEIGHT;
RUN;

Data Project_7(KEEP = COUNT CHILDREN EDUCA_COST_WT CAL_EDUCA_COST CAL_POPWEIGHT);
SET EDU_SUMMARY; 

/* CALCULATE CALENDAR YEAR MEAN EDUCATION EXPENDITURES */
CAL_EDUCA_COST = EDUCA_COST_WT / CAL_POPWEIGHT;

RUN; 

PROC PRINT DATA= PROJECT_7 LABEL NOOBS;
   VAR COUNT CHILDREN CAL_EDUCA_COST CAL_POPWEIGHT;

  /* INCLUDE FORMATS */
   FORMAT CAL_EDUCA_COST DOLLAR18.2;
   FORMAT CAL_POPWEIGHT COMMA15.;

   TITLE2 "AVERAGE ANNUAL (CALENDAR YEAR) WEIGHTED EDUCATION EXPENDITURE BY NUMBER OF CHILDREN IN THE CU";
   LABEL	CHILDREN 	   = '# of Children'
			CAL_EDUCA_COST = 'Average Annual Education Expense'
			CAL_POPWEIGHT  = 'Population';
RUN; 


/*******************************************************************************/
/********************************* PROJECT 8 ***********************************/
/*******************************************************************************/
/******************* User’s Guide to Income Imputation in the CE ***************/
/*******************************************************************************/
/*************** Unweighted means and total standard errors ********************/
/*************** Collection year                            ********************/
/*******************************************************************************/
/*******************************************************************************/

TITLE1 "PROJECT 8";

/* CREATE DATA SET CONTAINING DATA FOR A COLLECTION YEAR FROM 4 QUARTERLY FMLI FILES */
DATA FMLI (KEEP = NEWID REGION FINCBTX1-FINCBTX5);
	SET INI20.FMLI211 INI.FMLI212 INI.FMLI213 INI.FMLI214;
	

PROC SORT DATA = FMLI;
	BY REGION; 
	RUN;

/* SAS CODE TO OBTAIN BASIC DATA FOR ANSWERS */
/* GET THE MEAN AND STANDARD ERROR OF THE MEAN OF EACH OF THE FIVE COLUMNS */
PROC MEANS DATA = FMLI N MEAN STDERR STACKODSOUTPUT;
BY REGION;
TITLE2 "MEAN AND STANDARD ERROR OF EACH COLUMN OF MULTIPLY IMPUTED DATA";
    VAR FINCBTX1 - FINCBTX5;
	ODS OUTPUT SUMMARY = MEANSOUTPUT;
RUN;

/* GET VARIANCE OF THE MEAN OF EACH OF THE FIVE COLUMNS */
DATA MEANSOUTPUT;
SET MEANSOUTPUT;
VARIANCE = STDERR**2;
RUN;

/* GET MEAN OF THE MEANS, MEAN OF THE VARIANCES, AND VARIANCE OF THE MEANS */
PROC MEANS DATA = MEANSOUTPUT NOPRINT N MEAN VAR;
	BY REGION; 
	VAR MEAN VARIANCE;
		OUTPUT 	OUT = PROJECT_8	
			   MEAN = MEAN_MEANS MEAN_VAR
			    VAR = VAR_MEANS;
			RUN; 

/* COMBINE RESULTS TO GET THE TOTAL STANDARD ERRORS FOR MULTIPLY IMPUTED DATA */
data PROJECT_8;
set PROJECT_8;
TOTAL_VARIANCE = MEAN_VAR + (1.2  *  VAR_MEANS);
TOTAL_STDERR = SQRT(TOTAL_VARIANCE);
run;

PROC PRINT DATA = PROJECT_8  LABEL NOOBS;
    VAR REGION MEAN_MEANS TOTAL_STDERR;

/* INCLUDE FORMATS */
    FORMAT MEAN_MEANS TOTAL_STDERR DOLLAR15.2;

	TITLE2 "MEAN AND TOTAL STANDARD ERROR OF VARIABLE FINCBTXM";
	TITLE3 "INCOME IMPUTED VARIABLE BY REGION";

	LABEL 	MEAN_MEANS   = 'Mean Income Before Tax'
			TOTAL_STDERR = 'Total Standard error of Income';
RUN;

/*******************************************************************************/
/********************************* PROJECT 8A **********************************/
/*******************************************************************************/
/******************* User’s Guide to Income Imputation in the CE ***************/
/*******************************************************************************/
/*******************************************************************************/
/************************* Bonus code ******************************************/
/*******************************************************************************/
/***************** Weighted means and total standard errors ********************/
/*******************************************************************************/
/*******************************************************************************/

TITLE1 "PROJECT 8A BONUS CODE FOR WEIGHTED DATA ";

/* CREATE DATA SET CONTAINING DATA FOR A COLLECTION YEAR FROM 4 QUARTERLY FMLI FILES */
DATA FMLI (KEEP = NEWID FINCBTX1-FINCBTX5 FSALARY1-FSALARY5 FINLWT21 WTREP01-WTREP44);

	SET INI20.FMLI211 INI.FMLI212 INI.FMLI213 INI.FMLI214;

/* CREATE ARRAY OF WEIGHTS: CONVERT MISSING WEIGHTS TO ZERO, AND ANNUALIZE WEIGHTS FOR COLLECTION YEAR ESTIMATES */
      ARRAY A(45) WTREP01-WTREP44 FINLWT21;

      DO I=1 TO 45;
         IF A(I) < 0 THEN A(I) = 0;   /* CONVERT MISSING WEIGHTS TO ZERO */
         A(I) = A(I) / 4;  /* ANNUALIZE WEIGHTS, DIVIDE WEIGHTS BY NUMBER OF QUARTERS USED */
        DROP I; 
       END;
RUN;

/* DATASET TO BE USED IN MULTIPLE IMPUTED DATA ANALYSIS: MEANS AND TOTAL STANDARD ERRORS */
/* THIS DATASET HAVE THE FIVE INCOME FINCBTX1 - FINCBTX5 VARIABLES IN ONE COLUMN AND RENAME THEM AS FINCBTX */
/* CREATE INPUTATION IDENTIFIER VARIABLE */
data MIFMLI(DROP = FINCBTX1-FINCBTX5 FSALARY1-FSALARY5);
set FMLI; 
	_Imputation_ = 1;
	FINCBTX = FINCBTX1;
	FSALARY = FSALARY1;
output;
set FMLI; 
	_Imputation_ = 2;
	FINCBTX = FINCBTX2;
	FSALARY = FSALARY2;
output;
set FMLI; 
	_Imputation_ = 3;
	FINCBTX = FINCBTX3;
	FSALARY = FSALARY3;
output;
set FMLI; 
	_Imputation_ = 4;
	FINCBTX = FINCBTX4;
	FSALARY = FSALARY4;
output;
set FMLI; 
	_Imputation_ = 5;
	FINCBTX = FINCBTX5;
	FSALARY = FSALARY5;
output;
run;

PROC SORT DATA = MIFMLI;
BY _Imputation_; 
RUN;

/***************************************************************************************/
/* GET MEANS AND STANDARD ERRORS FOR MULTIPLE IMPUTED WEIGHTED DATA */
ODS LISTING CLOSE;  /* close the LISTING destination */
	PROC SURVEYMEANS data=MIFMLI VARMETHOD=BRR MEAN NOBS CV CLM ALPHA = .05; 
	TITLE2 "WEIGHTED SURVEYMEANS";
   	VAR  FINCBTX FSALARY; 
   	weight FINLWT21;
   	REPWEIGHTS WTREP01-WTREP44;
	DOMAIN _Imputation_;
   	ODS OUTPUT Domain = MyDomain;
	RUN;
ODS LISTING;  /* open the LISTING destination */

/* IF ANALYSIS FOR MORE THAN ONE VARIABLE THEN SORT THE DATASET */
PROC SORT DATA=MyDomain;
BY VARNAME;
RUN;

/* RUN PROC MIANALYZE FOR WEIGHTED DATA */
/* ERROR DEGREES OF FREEDOM = 44 */
	PROC MIANALYZE data=MyDomain EDF = 44 ALPHA = .05;
	TITLE2 "SURVEYMEANS RESULTS FOR WEIGHTED MULTIPLE IMPUTED DATA";
    TITLE3 "WEIGHTED DATA, STANDARD ERRORS USING BRR";
	BY VARNAME; /* IF ANALYSIS FOR MORE THAN ONE VARIABLE IS REQUESTED */
	MODELEFFECTS MEAN;
	  STDERR STDERR;
	RUN;

/*******************************************************************************/
/********************************* PROJECT 9 ***********************************/
/*******************************************************************************/
/******************* User’s Guide to Income Imputation in the CE ***************/
/*******************************************************************************/
/**************************** Unweighted regressions ***************************/
/*******************************************************************************/

TITLE1 "PROJECT 9";

/* CREATE DATA SET CONTAINING DATA FOR A COLLECTION YEAR FROM 4 QUARTERLY FMLI FILES */
DATA FMLI (KEEP = NEWID FINCBTX1-FINCBTX5 FDHOME);
	SET INI20.FMLI211 INI.FMLI212 INI.FMLI213 INI.FMLI214;

/* CREATE ANNUALIZED QUARTERLY FOOD AT HOME EXPENSE */
	FDHOME = (FDHOMECQ + FDHOMEPQ) * 4;

RUN;

PROC SORT DATA = FMLI;
	BY NEWID;
	RUN;

/* RUN THE REGRESSION MODEL ONE TIME FOR EACH OF THE FIVE IMPUTED VARIABLES */
PROC REG DATA = FMLI; 
 TITLE2 "MODEL: FDHOME = FINCBTX1";
 MODEL FDHOME = FINCBTX1; 
 ODS OUTPUT PARAMETERESTIMATES = MODEL1; 
QUIT;

PROC REG DATA = FMLI; 
 TITLE2 "MODEL: FDHOME = FINCBTX2";
 MODEL FDHOME = FINCBTX2; 
ODS OUTPUT PARAMETERESTIMATES = MODEL2; 
QUIT;

PROC REG DATA = FMLI; 
 TITLE2 "MODEL: FDHOME = FINCBTX3";
 MODEL FDHOME = FINCBTX3; 
ODS OUTPUT PARAMETERESTIMATES = MODEL3; 
QUIT;

PROC REG DATA = FMLI; 
 TITLE2 "MODEL: FDHOME = FINCBTX4";
 MODEL FDHOME = FINCBTX4; 
ODS OUTPUT PARAMETERESTIMATES = MODEL4; 
QUIT;

PROC REG DATA = FMLI; 
 TITLE2 "MODEL: FDHOME = FINCBTX5";
 MODEL FDHOME = FINCBTX5; 
ODS OUTPUT PARAMETERESTIMATES = MODEL5; 
QUIT;

/* CREATE DATASET WITH RESULTS OF ALL FIVE REGRESSIONS */
DATA MODELS; 
	SET MODEL1 - MODEL5; 
	IF Variable = "Intercept" THEN TYPE = "INTERCEPT";
	ELSE TYPE = "MPC";
	Variance = StdErr ** 2;
	RUN; 

PROC SORT DATA = MODELS; 
BY TYPE; 
RUN; 

/* GET MEAN AND VARIANCE OF THE FIVE REGRESSIONS */
PROC MEANS DATA = MODELS NOPRINT N MEAN VAR;
	BY TYPE; 
	VAR Estimate Variance;
		OUTPUT 	OUT = MODELSOUTPUT	
			   MEAN = ESTIMATE MEAN_VARIANCE
				VAR = VAR_MEANS;
			RUN; 

/* COMBINE RESULTS TO GET THE TOTAL VARIANCE AND TOTAL STANDARD ERRORS FOR INCOME IMPUTATION DATA */
data PROJECT_9;
set MODELSOUTPUT;
TOTAL_VARIANCE = MEAN_VARIANCE + (1.2  *  VAR_MEANS);
TOTAL_STDERR = SQRT(TOTAL_VARIANCE);
run;
/* PRINT RESULTS */
PROC PRINT DATA = PROJECT_9 LABEL NOOBS;
   TITLE2 "Results for regressions using unweighted multiple imputed data";
   TITLE3 "Income Imputation Results for unweighted data";
   VAR TYPE ESTIMATE TOTAL_VARIANCE TOTAL_STDERR;

  /* INCLUDE FORMATS */
   FORMAT ESTIMATE COMMA15.2 TOTAL_VARIANCE  TOTAL_STDERR D11.3;

   LABEL	TYPE					= 'Type'
			ESTIMATE 	      		= 'Estimate'
			TOTAL_VARIANCE 			= 'Total Variance'
			TOTAL_STDERR			= 'Total Standard Error';

RUN;

/*******************************************************************************/
/********************************* PROJECT 9A **********************************/
/*******************************************************************************/
/******************* User’s Guide to Income Imputation in the CE ***************/
/*******************************************************************************/
/*******************************************************************************/
/************************* Bonus code ******************************************/
/*******************************************************************************/
/********************* Weighted regressions ************************************/
/*******************************************************************************/
/*******************************************************************************/


TITLE1 "PROJECT 9A BONUS CODE FOR WEIGHTED DATA ";

/* CREATE DATA SET CONTAINING DATA FOR A COLLECTION YEAR FROM 4 QUARTERLY FMLI FILES */
DATA FMLI (KEEP = NEWID FDHOME FINCBTX1-FINCBTX5 FINLWT21 WTREP01-WTREP44);

	SET INI20.FMLI211 INI.FMLI212 INI.FMLI213 INI.FMLI214;

/* CREATE ARRAY OF WEIGHTS: CONVERT MISSING WEIGHTS TO ZERO, AND ANNUALIZE WEIGHTS FOR COLLECTION YEAR ESTIMATES */
      ARRAY A(45) WTREP01-WTREP44 FINLWT21;

      DO I=1 TO 45;
         IF A(I) < 0 THEN A(I) = 0;   /* CONVERT MISSING WEIGHTS TO ZERO */
         A(I) = A(I) / 4;  /* ANNUALIZE WEIGHTS, DIVIDE WEIGHTS BY NUMBER OF QUARTERS USED */
        DROP I; 
       END;

/* CREATE FOOD AT HOME VARIABLE BY ADDING CURRENT QUARTER AND PREVIOUS QUARTER VARIABLES */
	FDHOME = (FDHOMECQ + FDHOMEPQ)*4;           /* ANNUALIZE EXPENDITURES */
RUN;

/* DATASET TO BE USED IN MULTIPLE IMPUTED DATA ANALYSIS: REGRESSIONS */
/* THIS DATASET HAVE THE FIVE INCOME FINCBTX1 - FINCBTX5 VARIABLES IN ONE COLUMN AND RENAME THEM AS FINCBTX */
/* CREATE INPUTATION IDENTIFIER VARIABLE */
data MIFMLI(DROP = FINCBTX1-FINCBTX5);
set FMLI; 
	_Imputation_ = 1;
	FINCBTX = FINCBTX1;
output;
set FMLI; 
	_Imputation_ = 2;
	FINCBTX = FINCBTX2;
output;
set FMLI; 
	_Imputation_ = 3;
	FINCBTX = FINCBTX3;
output;
set FMLI; 
	_Imputation_ = 4;
	FINCBTX = FINCBTX4;
output;
set FMLI; 
	_Imputation_ = 5;
	FINCBTX = FINCBTX5;
output;
run;

PROC SORT DATA = MIFMLI;
BY _Imputation_; 
RUN;

/* REGRESSIONS FOR MULTIPLE IMPUTED WEIGHTED DATA */
ODS LISTING CLOSE;    /* close the LISTING destination */
PROC SURVEYREG  DATA=MIFMLI varmethod=BRR alpha=.05;
	TITLE2 "SURVEYREG FOR WEIGHTED MULTIPLE IMPUTED DATA";
   	weight FINLWT21; 
   	REPWEIGHTS wtrep01 - wtrep44;
	DOMAIN _imputation_;
	MODEL FDHOME = FINCBTX/SOLUTION df = 44 ;
	ODS OUTPUT ParameterEstimates=INCIMP_WEIGHTEDDATASET (WHERE=(_Imputation_ NE . ));
QUIT;
ODS LISTING ;    /* open the LISTING destination */

/* RUN PROC MIANALYZE FOR WEIGHTED DATA */
/* ERROR DEGREES OF FREEDOM = 44 */
PROC MIANALYZE parms=INCIMP_WEIGHTEDDATASET  ALPHA=.05 EDF=44;
	TITLE2 "SURVEYREG RESULTS FOR WEIGHTED MULTIPLE IMPUTED DATA";
	MODELEFFECTS Intercept FINCBTX;
RUN;


/*******************************************************************************/
/********************************* PROJECT 10 **********************************/
/*******************************************************************************/
/***************************Economic Impact Payment ****************************/
/*******************************************************************************/
/*******************************************************************************/
/*******************************************************************************/
/*******************************************************************************/
/*******************************************************************************/
/*******************************************************************************/
/*******************************************************************************/



/* Sets fmli files into a work version */

data fmly_Q1;
	set INI20.fmli201 (keep=NEWID EENTRMTC EENTRMTP);
	EENTRMT=sum(0,EENTRMTC,EENTRMTP);
run;

data fmly_Q2;
	set INI20.fmli202 (keep=NEWID age_ref EENTRMTC EENTRMTP);
	EENTRMT=sum(0,EENTRMTC,EENTRMTP);
run;


/* Filters the CNT dataset by those who have reported receipt of an Economic Impact Payment, or EIP (contcode='800') */

data EIP_yes;
	set INE20.cnt20;
	EIP_count=1;
	if contcode = '800' then output;
run;

proc sort data=EIP_yes;
   by NEWID;
run;

/* Code to add up the records with more than one EIP per household into one record */

proc summary nway data=EIP_yes;
   by NEWID;
   var EIP_count contexpx;
   output out=EIP_data sum= EIP_count contexpx_per_cu;
run;

/* Sort in order to merge the two files */

proc sort data=fmly_Q2;
	by NEWID;
run;

proc sort data=EIP_data;
	 by NEWID;
run; /* Data should already be sorted in correct order, but this step makes sure */

/* Merges the FMLY dataset with the CNT dataset */

data EIP_status;
	merge fmly_Q2 (in=fmly) EIP_data (in=expn);
	by NEWID;
	if fmly;

	CONTEXPX_PER_CU=sum(0,contexpx_per_cu); /* Converts missing values to 0. */

	EIP_count=sum(0,EIP_count); /* Converts missing values to 0. */

	EIP_received=(EIP_count>=1);
run;

/* Produce table showing percent receiving EIPs */

proc format;
   value no_yes
      0="No"
      1="Yes"
      ;
run;

proc freq data=EIP_status;
   tables EIP_received/missing; /* Ensure there are no missings--only "0" or "1" */
   format EIP_received no_yes.;
  title "Table showing (unweighted) number, percentage of consumer units receiving at least one EIP.";
run;

/* To compute means of EIP received by recipients */

proc sort data=EIP_status;
   by EIP_received;
run;

proc means data=EIP_status n mean min max sum;  /* Compute mean, plus some descriptive statistics to check code */
   by EIP_received;
   format EIP_received no_yes.;
   title "Mean of Economic Impact Payment (EIP) amount (CONTEXPX_PER_CU) for recipients.";
   title2 "Expected value is $0 for non-recipients, >$0 for recipients.";
run;

/* Compute mean entertainment outlays in 2020Q1, then 2020Q2 */

proc means data=fmly_Q1 n mean min max sum;
   var EENTRMT;
   title "Compute unweighted mean entertainment outlays in 2020Q1";
run;

proc means data=fmly_Q2 n mean min max sum;
   var EENTRMT;
   title "Compute unweighted mean entertainment outlays in 2020Q2";
run;

/* For 2020Q2, compute by receipt of EIP */

proc sort data=EIP_status;
   by EIP_received;
run;

proc means data=EIP_status n mean min max sum;
   by EIP_received;
   var EENTRMT;
   format EIP_received no_yes.;
   title "Compute unweighted mean entertainment outlays in 2020Q2 by receipt of at least one EIP";
run;

/* Compare entertainment outlays in 2020Q2 for consumer units receiving only one EIP by main use of EIP */

data received_one_EIP_only;
   set EIP_status;
   if EIP_count=1;
run;

proc sort data=received_one_EIP_only;
   by NEWID;
run;

data single_EIP_cus;
   merge received_one_EIP_only (in=only_one) EIP_yes;
   by NEWID;
   if only_one;
run;

proc format;
   value $rebtused
      " "="Unknown use; record is blank"
      "1"="Mostly to pay for expenses"
	  "2"="Mostly to pay off debt"
	  "3"="Mostly to add to savings"
	  ;

proc sort data=single_EIP_cus;
   by rebtused;
run;

proc means data=single_EIP_cus n mean min max sum;
   var EENTRMT;
   by rebtused;
   format rebtused $rebtused.;
   title "Compute unweighted mean entertainment outlays in 2020Q2 by main use of (single) EIP received.";
run;

