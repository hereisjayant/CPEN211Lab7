/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    DOT_ORG = 258,
    DOT_SECTION = 259,
    DOT_TEXT = 260,
    DOT_DATA = 261,
    DOT_WORD = 262,
    DOT_EQU = 263,
    DOT_GLOBAL = 264,
    B = 265,
    BEQ = 266,
    BNE = 267,
    BLT = 268,
    BLE = 269,
    BL = 270,
    BLX = 271,
    BX = 272,
    LDR = 273,
    STR = 274,
    ADD = 275,
    AND = 276,
    CMP = 277,
    MVN = 278,
    MOV = 279,
    LSL = 280,
    LSR = 281,
    ASR = 282,
    NOP = 283,
    HALT = 284,
    DLLR = 285,
    NUMB = 286,
    PERC = 287,
    NEW_LINE = 288,
    REGISTER = 289,
    REG_LR = 290,
    LABEL = 291,
    LABEL_DEF = 292,
    DEC_NUMBER = 293,
    BIN_NUMBER = 294,
    HEX_NUMBER = 295
  };
#endif
/* Tokens.  */
#define DOT_ORG 258
#define DOT_SECTION 259
#define DOT_TEXT 260
#define DOT_DATA 261
#define DOT_WORD 262
#define DOT_EQU 263
#define DOT_GLOBAL 264
#define B 265
#define BEQ 266
#define BNE 267
#define BLT 268
#define BLE 269
#define BL 270
#define BLX 271
#define BX 272
#define LDR 273
#define STR 274
#define ADD 275
#define AND 276
#define CMP 277
#define MVN 278
#define MOV 279
#define LSL 280
#define LSR 281
#define ASR 282
#define NOP 283
#define HALT 284
#define DLLR 285
#define NUMB 286
#define PERC 287
#define NEW_LINE 288
#define REGISTER 289
#define REG_LR 290
#define LABEL 291
#define LABEL_DEF 292
#define DEC_NUMBER 293
#define BIN_NUMBER 294
#define HEX_NUMBER 295

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 21 "sas.y"

  int   integer_value;
  float float_value;
  char *string_value;

#line 143 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
