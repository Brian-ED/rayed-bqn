# Command line variables
inFileName ← "../src/raylib.h"
outFileName ← "raylib_api.txt"
apiDefine ← "RLAPI"       # Functions define (i.e. RLAPI for raylib.h, RMDEF for raymath.h, etc.)
truncAfter ← ""           # Truncate marker (i.e. "RLGL IMPLEMENTATION" for rlgl.h)

"
    raylib API parser

    This parser scans raylib.h to get API information about defines, structs, aliases, enums, callbacks and functions.
    All data is divided into pieces, usually as strings. The following types are used for data:

     - struct DefineInfo
     - struct StructInfo
     - struct AliasInfo
     - struct EnumInfo
     - struct FunctionInfo

    CONSTRAINTS:

    This parser is specifically designed to work with raylib.h, so, it has some constraints:

     - Functions are expected as a single line with the following structure:

       <retType> <name>(<paramType[0]> <paramName[0]>, <paramType[1]> <paramName[1]>);  <desc>

       Be careful with functions broken into several lines, it breaks the process!

     - Structures are expected as several lines with the following form:

       <desc>
       typedef struct <name> {
           <fieldType[0]> <fieldName[0]>;  <fieldDesc[0]>
           <fieldType[1]> <fieldName[1]>;  <fieldDesc[1]>
           <fieldType[2]> <fieldName[2]>;  <fieldDesc[2]>
       } <name>;

     - Enums are expected as several lines with the following form:

       <desc>
       typedef enum {
           <valueName[0]> = <valueInteger[0]>, <valueDesc[0]>
           <valueName[1]>,
           <valueName[2]>, <valueDesc[2]>
           <valueName[3]>  <valueDesc[3]>
       } <name>;

       NOTE: Multiple options are supported for enums:
          - If value is not provided, (<valueInteger[i -1]> + 1) is assigned
          - Value description can be provided or not

    OTHER NOTES:

     - This parser could work with other C header files if mentioned constraints are followed.
     - This parser does not require <string.h> library, all data is parsed directly from char buffers.

    LICENSE: zlib/libpng

    raylib-parser is licensed under an unmodified zlib/libpng license, which is an OSI-certified,
    BSD-like license that allows static linking with closed source software:

    Copyright (c) 2021-2023 Ramon Santamaria (@raysan5)

**********************************************************************************************/
"
max_defines_to_parse    ← 2048 # Maximum number of defines to parse
max_structs_to_parse    ←   64 # Maximum number of structures to parse
max_aliases_to_parse    ←   64 # Maximum number of aliases to parse
max_enums_to_parse      ←   64 # Maximum number of enums to parse
max_callbacks_to_parse  ←   64 # Maximum number of callbacks to parse
max_funcs_to_parse      ← 1024 # Maximum number of functions to parse
max_line_length         ←  512 # Maximum length of one line (including comments)
max_struct_fields       ←   64 # Maximum number of struct fields
max_enum_values         ←  512 # Maximum number of enum values
max_function_parameters ←   12 # Maximum number of function parameters

If      ← {𝕏⍟𝕎@}´                 # Also Repeat
IfElse  ← {c‿T‿F: c◶F‿T@}
While   ← {𝕩•_while_𝕨@}´          # While 1‿{... to run forever
DoWhile ← {𝕏@ ⋄ While 𝕨‿𝕩}´
For     ← {I‿C‿P‿A: I@ ⋄ While⟨C,P∘A⟩}

# Switch/case statements have many variations; these are a few
Match   ← {𝕏𝕨}´
Select  ← {(⊑𝕩)◶(1↓𝕩)@}
Switch  ← {c←⊑𝕩 ⋄ [m,a]←⍉∘‿2⥊1↓𝕩 ⋄ (m⊸⊐⌾<C)◶a@}
Test    ← {fn←{C‿A𝕊e:C◶A‿E}´𝕩⋄Fn@}

tab←9+@

#----------------------------------------------------------------------------------
# Types and Structures Definition
#----------------------------------------------------------------------------------

# Type of parsed define
⟨
    unknown
    macro
    guard
    int
    int_math
    long
    long_math
    float
    float_math
    double
    double_math
    char
    string
    coloR
⟩ ← ↕14

# Struct info data
structInfo ← ⟨
    0‿64 ⥊""  # name       # Struct name
    0‿128⥊""  # desc       # Struct type description
    ↕0        # fieldCount # Number of fields in the struct
    0‿max_struct_fields‿64 ⥊""  # fieldType  # Field type
    0‿max_struct_fields‿64 ⥊""  # fieldName  # Field name
    0‿max_struct_fields‿128⥊""  # fieldDesc  # Field description
⟩

# Alias info data
aliasInfo ← ⟨
    0‿64 ⥊"" # type # Alias type
    0‿64 ⥊"" # name # Alias name
    0‿128⥊"" # desc # Alias description
⟩

# Enum info data
enumInfo ← ⟨
    0‿64 ⥊"" # name       # Enum name
    0‿128⥊"" # desc       # Enum description
    ↕0     # valueCount # Number of values in enumerator
    0‿max_enum_values‿64⥊""  # valueName    # Value name definition
    0‿max_enum_values⥊↕0     # valueInteger # Value integer
    0‿max_enum_values‿128⥊"" # valueDesc    # Value description
⟩

# Function info data
FunctionInfo ← ⟨
    0‿64 ⥊"" # name        # Function name
    0‿128⥊"" # desc        # Function description (comment at the end)
    0‿32 ⥊"" # retType     # Return value type
    ↕0       # paramCount  # Number of function parameters
    0‿max_function_parameters‿32 ⥊""paramType # Parameters type
    0‿max_function_parameters‿32 ⥊""paramName # Parameters name
    0‿max_function_parameters‿128⥊""paramDesc # Parameters description
⟩

#----------------------------------------------------------------------------------
# Global Variables Definition
#----------------------------------------------------------------------------------
defineCount ← 0
structCount ← 0
aliasCount ← 0
enumCount ← 0
callbackCount ← 0
funcCount ← 0
defines ← @
structs ← @
aliases ← @
enums ← @
callbacks ← @
funcs ← @

#----------------------------------------------------------------------------------
# Module Functions Definition
#----------------------------------------------------------------------------------

# Get data type and name from a string containing both
# NOTE: Useful to parse function parameters and struct fields
static void GetDataTypeAndName(const char *typeName, int typeNameLen, char *type, char *name)
{
    for (int k = typeNameLen; k > 0; k--)
    {
        if ((typeName[k] == ' ') && (typeName[k - 1] != ','))
        {
            # Function name starts at this point (and ret type finishes at this point)
            MemoryCopy(type, typeName, k);
            MemoryCopy(name, typeName + k + 1, typeNameLen - k - 1);
            break;
        }
        else if (typeName[k] == '*')
        {
            MemoryCopy(type, typeName, k + 1);
            MemoryCopy(name, typeName + k + 1, typeNameLen - k - 1);
            break;
        }
        else if ((typeName[k] == '.') && (typeNameLen == 3)) # Handle varargs ...);
        {
            MemoryCopy(type, "...", 3);
            MemoryCopy(name, "args", 4);
            break;
        }
    }
}

# Get comment from a line, do nothing if no comment in line
static void GetDescription{𝕊line: # str → description (str)
    c ← 0
    descStart ← ¯1
    lastSlash ← ¯2
    isValid ← 0
    
    {isValid ∧ (descStart=¯1) ∧ 𝕩≠' '?
        descStart ↩ c
    ;'/'=𝕩?
        isValid ↩ lastSlash=c-1
        lastSlash ↩ c
    ;@
    }¨line
    ""⍟(descStart≠¯1) (c-descStart)↑descStart↓line
}

# Move array size from name to type
MoveArraySize←{𝕊name‿type:
    int nameLength = TextLength(name);
    if (name[nameLength - 1] == ']')
    {
        for (int k = nameLength; k > 0; k--)
        {
            if (name[k] == '[')
            {
                int sizeLength = nameLength - k;
                MemoryCopy(&type[TextLength(type)], &name[k], sizeLength);
                name[k] ↩ @
            }
        }
    }
}

# Compare two text strings, requires number of characters to compare
IsTextEqual{𝕊text1‿text2‿count:
    ≡´count↑¨text1‿text2
}

# Find first text occurrence within a string
TextFindIndex ← ⊑¯1∾˜/∘⍷

# Get string of define type
StrDefineType ← ⊑⟜⟨
    "UNKNOWN"
    "GUARD"
    "MACRO"
    "INT"
    "INT_MATH"
    "LONG"
    "LONG_MATH"
    "FLOAT"
    "FLOAT_MATH"
    "DOUBLE"
    "DOUBLE_MATH"
    "CHAR"
    "STRING"
    "COLOR"
⟩

# Export parsed data in json
ExportParsedData ← {𝕊filename:
    fileName⊸•FLines ∾⟨𝕊def:
        "{"

        # Print defines info
        "  ""defines"": ["
        ¯1⊸↓⌾(¯1⊸⊑)∾{𝕊def:∾⟨
            ⋈"    {"
            ⋈"      ""name"": """∾def.name∾""","
            ⋈"      ""type"": """∾(StrDefineType def.type)∾""","
            {def.isHex? # INT or LONG
                "      ""value"": "∾(Strtol def.value‿NULL‿16)∾","
            ;∨´def.type = INT‿LONG‿FLOAT‿DOUBLE‿STRING?
                "      ""value"": "∾def.value∾','
            ;
                "      ""value"": """∾def.value∾""","
            }
            ⋈"      ""description"": """∾def.desc∾""""
            ⋈"    },"
        ⟩}¨defines
        "  ],"
        # Print structs info
        "  ""structs"": ["
        ¯1⊸↓⌾(¯1⊸⊑)∾{𝕊struct:⟨
            ⋈"    {"
            ⋈"      ""name"": """∾struct.name∾""","
            ⋈"      ""description"": """∾(EscapeBackslashes struct.desc)∾""","
            ⋈"      ""fields"": ["
            ∾¯1⊸↓⌾(¯1⊸⊑){𝕊f:⟨
                "        {"
                "          ""type"": """∾struct.fieldType[f]∾""","
                "          ""name"": """∾struct.fieldName[f]∾""","
                "          ""description"": """∾(EscapeBackslashes struct.fieldDesc[f])∾""""
                "        },"
            ⟩}¨↕struct.fieldCount
            ⋈"      ]"
            ⋈"    },"
        ⟩}¨structs
        "  ],"

        # Print aliases info
        "  ""aliases"": ["
        ¯1⊸↓⌾(¯1⊸⊑)∾{𝕊alias:⟨
            "    {"
            "      ""type"": """∾alias.type∾""","
            "      ""name"": """∾alias.name∾""","
            "      ""description"": """∾alias.desc∾'"'
            "    },"
        ⟩}¨aliases
        ⋈"  ],"

        # Print enums info
        ⋈"  ""enums"": ["
        ¯1⊸↓⌾(¯1⊸⊑)∾{𝕊enum:
            ∾⟨
                ⋈"    {"
                ⋈"      ""name"": """∾enum.name∾""","
                ⋈"      ""description"": """∾(EscapeBackslashes enum.desc)∾""","
                ⋈"      ""values"": ["
                ¯1⊸↓⌾(¯1⊸⊑)∾{𝕊e:
                    ⟨
                        "        {"
                        "          ""name"": """∾enum.valueName[e]∾""","
                        "          ""value"": "∾enum.valueInteger[e]∾","
                        "          ""description"": """∾(EscapeBackslashes enum.valueDesc[e])∾'"'
                        "        },"
                    ⟩
                }¨↕enum.valueCount
                ⋈"      ]"
                ⋈"    },"
            ⟩
        }↕enums
        ⋈"  ],"

        # Print callbacks info
        ⋈"  ""callbacks"": ["
        for (int i = 0; i < callbackCount; i++)
        ¯1⊸↓⌾(¯1⊸⊑)∾{𝕊callback:∾⟨
            ⋈"    {"
            ⋈"      ""name"": """∾callback.name∾""","
            ⋈"      ""description"": """∾(EscapeBackslashes callback.desc)∾""",",
            ⋈"      ""returnType"": """∾callback.retType∾""","
            ⋈"      ""params"": ["
            ¯1⊸↓⌾(¯1⊸⊑)∾{𝕊p:
                "        {"
                "          ""type"": """∾callback.paramType[p]∾"""," 
                "          ""name"": """∾callback.paramName[p]∾""""  
                "        },"
            }¨↕callback.paramCount
            ⋈"      ]"
            ⋈"    },"
        ⟩}¨callbacks
        "  ],"

        # Print functions info
        ⋈"  ""functions"": ["
        ¯1⊸↓⌾(¯1⊸⊑)∾{𝕊func: ∾⟨
            ⋈"    {"
            ⋈"      ""name"": """∾func.name∾""","
            ⋈"      ""description"": """∾(EscapeBackslashes func.desc)∾""","
            ⋈"      ""returnType"": """∾func.retType∾""","
            ∾⟨
                "      ""params"": ["
                ∾{type𝕊name:⟨
                    "        {"
                    "          ""type"": """∾type∾""","
                    "          ""name"": """∾name∾'"'
                    "        }"
                    ","
                ⟩}¨´func.paramType‿func.paramName
                ⋈"      ]"
            ⟩
            "    },"
        ⟩}¨funcs
        ⋈"  ]"
        ⋈"}"
    ⟩
}

#----------------------------------------------------------------------------------
# Program main entry point
#----------------------------------------------------------------------------------

# Preprocess buffer to get separate lines
# NOTE: GetTextLines() also removes leading spaces/tabs
lines ← •FLines inFileName
linesCount ← ≠lines

# Truncate lines
{𝕤
    int newCount = -1;
    For (i←0)‿{𝕊:i<linesCount}‿{𝕊:i+↩1}‿{
        newCount>¯1? free(lines[i]);
        TextFindIndex(lines[i], truncAfter)>¯1? newCount ↩ i;
        ;0
    }
    {𝕊:linesCount↩newCount}⍟⊢newCount > -1
    "Number of truncated text lines: "∾•ParseFloat linesCount
}⍟⊢0<≠truncAfter

# Defines line indices
int *defineLines = (int *)malloc(MAX_DEFINES_TO_PARSE*sizeof(int));

# Structs line indices
int *structLines = (int *)malloc(MAX_STRUCTS_TO_PARSE*sizeof(int));

# Aliases line indices
int *aliasLines = (int *)malloc(MAX_ALIASES_TO_PARSE*sizeof(int));

# Enums line indices
int *enumLines = (int *)malloc(MAX_ENUMS_TO_PARSE*sizeof(int));

# Callbacks line indices
int *callbackLines = (int *)malloc(MAX_CALLBACKS_TO_PARSE*sizeof(int));

# Function line indices
int *funcLines = (int *)malloc(MAX_FUNCS_TO_PARSE*sizeof(int));

# Prepare required lines for parsing
#----------------------------------------------------------------------------------

# Read struct lines
# Find structs
# starting with "typedef struct ... {" or "typedef struct ... ; \n struct ... {"
# ending with "} ... ;"
# i.e. excluding "typedef struct rAudioBuffer rAudioBuffer;" -> Typedef and forward declaration only
structLines ← /{
    [m1,m2]←"typedef struct"‿"struct"(⊣≡≠⊸↑)⌜𝕩
    m1∧m2«⊸∨<´∘⊐⟜"{;"¨𝕩
} lines

# Read alias lines
# Find aliases (lines with "typedef ... ...;")
aliasLines ← ("typedef"⊸(⊣≡≠⊸↑)¨∧2=(+´¨' '⊸=>∨`¨∘∊⟜";("))lines

# Read enum lines
# Read enum line
# Keep the line position in the array of lines,
# so, we can scan that position and following lines
# ignore inline enums
enumLines ← ("typedef enum {"⊸(⊣≡≠⊸↑)∧∨´∘=⟜';')¨lines

# Read callback lines
callbackLines ← {
    # Find callbacks (lines with "typedef ... (* ... )( ... );")
    m1←"typedef"⊸(⊣≡≠⊸↑)¨lines
    m1∧{(");"⊸≡˘∨`⊸<")("⊸≡˘∧"(*"⊸≡˘)2↕𝕩}¨lines
}

# Read function lines
# Read function line (starting with `define`, i.e. for raylib.h "RLAPI")
funcLines ← apiDefine⊸(⊣≡≠⊸↑)¨lines

# At this point we have all raylib defines, structs, aliases, enums, callbacks, functions lines data to start parsing

# Parsing raylib data
#----------------------------------------------------------------------------------

# Define info data
defineIndicies ← {name‿type‿value‿desc‿isHex←↕5}

defMacro ← "#define"

CheckHex ← ¬·∨´∊⟜(∾⟨'0'+↕10⋄'a'+↕6⋄'A'+↕6⋄"xL.+-"⟩)

defines ← {
    linePtrs ← ↓⟜lines¨/defMacro⊸(⊣≡≠⊸↑)¨∨`∘∊⟜' '‿t⊸/¨lines
    loopedOver ← linePtrs
    
    # Skip duplicates
    ∊∘{defineIndicies.name⊑𝕩}⊸/defines⊣{𝕊linePtr:
        defineOut ← ⟨
            "" # str  # Define name
            @  # int  # Define type
            "" # str  # Define value
            "" # str  # Define description
            0  # bool # Define is hex number (for types INT, LONG)
        ⟩
        LS ← {∨`¬𝕩∊' '‿tab} # leading spacing
        nameAndArgs ← RS⊸/{𝔽defMacro∾⁼𝔽}linePtr # Skip spaces and tabs, then defMacro, then spaces and tabs again

        # Extract name
        defineNameStart ← linePtr-○≠nameAndArgs
        
        openBraces ← +`-˝"()"=⌜nameAndArgs
        •SHow (1+⊐⟜')')⊸(↑⋈↓)"hell)oo"
        
        nameLen ← defineNameEnd ← (⌊´∘⊐⟜' '‿tab≤·⊑⊐⟜'(')◶⟨
            1+⊐⟜')'
            ⌊´⊐⟜' '‿tab
        ⟩ nameAndArgs

        name‿args ← nameLen(↑⋈LS⊸/∘↓)nameAndArgs

        # Determine type
        {𝕊:defineOut macro⌾(defineIndicies.type⊸⊑)↩}⍟⊢')'=¯1⊑name
        {𝕊:defineOut guard⌾(defineIndicies.type⊸⊑)↩}⍟⊢(0=≠args)∨'/'=⊑args

        {'"'=⊑args? defineOut string⌾(defineIndicies.type⊸⊑)↩
        ;args=○⊑"'"? defineOut char⌾(defineIndicies.type⊸⊑)↩
        ;"CLITERAL(Color)"≡15↑args? defineOut color⌾(defineIndicies.type⊸⊑)↩
        ;⊑args⊑⊸∊'0'+↕10? # Parsing numbers
            isFloat‿isNumber‿isHex ← ⟨
                ⊑∊⟜'.'
                ⊑∊⟜'x'
                CheckHex
            ⟩{𝕎𝕩}¨<m←∧`∘¬∘∊⟜' '‿tab⊸/args
            {𝕊:isFloat?
                defineOut (double‿float⊑˜'f'=¯1⊑m)⌾(defineIndicies.type⊸⊑)↩
            ;
                defineOut (int‿long⊑˜'L'=¯1⊑m)⌾(defineIndicies.type⊸⊑)↩
                defineOut isHex⌾(defineIndicies.isHex⊸⊑)↩
            }⍟⊢isNumber
        }

        # Extracting value
        fullValue ← ∨`⌾⌽∘¬∘∊⟜tab‿' '⊸/args/˜¬∨`0∾˜"//"⍷args
        value ← fullValue↓˜-⊑defineOut.type∊long‿float # Remove number postfix
        
        defineOut value⌾(defineIndicies.value⊸⊑)↩

        # Extracting description
        args←"diw // dwa"
        desc ← ∨`∘≠⟜' '⊸/args↓˜2+⊑/"//"⍷args
        defineOut desc⌾(defineIndicies.desc⊸⊑)↩

        # Parse defines of type UNKNOWN to find calculated numbers
        breakHappened←0⥊˜≠defineOut.value
        {𝕤
            largestType ← unknown
            isMath ← 1

            {𝕊c:
                ch ← c⊑value

                # Skip operators and whitespace
                ¬⊑ch∊"()+-*/ "∾tab?
                    {ch∊'0'+↕10? # Read number operand
                        isNumber‿isFloat ← 1‿0
                        break←1
                        While {𝕊:break∧CheckHex ch}‿{
                            {𝕊:isFloat↩1}⍟⊢ch='.'
                            CheckHex ch?
                                isNumber ↩ 0
                                break↩0
                            ;
                            c+↩1
                            ch↩c⊑value
                        }
                        isNumber◶{𝕤
                            isMath = false;
                            break;
                        }‿{
                            # Found a valid number -> update largestType
                            int numberType;
                            if (isFloat) numberType = (value[c - 1] == 'f')? FLOAT_MATH : DOUBLE_MATH;
                            else numberType = (value[c - 1] == 'L')? LONG_MATH : INT_MATH;

                            if (numberType > largestType) largestType = numberType;
                        }
                    ; # Read string operand
                        int operandStart = c;
                        while (!((ch == '\0') ||
                                    (ch == ' ') ||
                                    (ch == '(') ||
                                    (ch == ')') ||
                                    (ch == '+') ||
                                    (ch == '-') ||
                                    (ch == '*') ||
                                    (ch == '/')))
                        {
                            c++;
                            ch = value[c];
                        }
                        int operandEnd = c;
                        int operandLength = operandEnd - operandStart;

                        # Search previous defines for operand
                        bool foundOperand = false;
                        for (int previousDefineIndex = 0; previousDefineIndex < defineIndex; previousDefineIndex++)
                        {
                            if (IsTextEqual(defines[previousDefineIndex].name, &value[operandStart], operandLength))
                            {
                                if ((defines[previousDefineIndex].type >= INT) && (defines[previousDefineIndex].type <= DOUBLE_MATH))
                                {
                                    # Found operand and it's a number -> update largestType
                                    if (defines[previousDefineIndex].type > largestType) largestType = defines[previousDefineIndex].type;
                                    foundOperand = true;
                                }
                                break;
                            }
                        }
                        if (!foundOperand)
                        {
                            isMath = false;
                            breakHappened 1⌾(c⊸⊑)↩ 
                        }
                    }
                ;@
            }¨↕≠defineOut.value

            if (isMath)
            {
                # Define is a calculated number -> update type
                if (largestType == INT) largestType = INT_MATH;
                else if (largestType == LONG) largestType = LONG_MATH;
                else if (largestType == FLOAT) largestType = FLOAT_MATH;
                else if (largestType == DOUBLE) largestType = DOUBLE_MATH;
                defineOut.type = largestType;
            }
        }⍟⊢defineOut.type=unknown

        defineOut
    }¨loopedOver
}
defineCount ← ≠defines

# Structs info data
structs = (StructInfo *)calloc(MAX_STRUCTS_TO_PARSE, sizeof(StructInfo));

for (int i = 0; i < structCount; i++)
{
    char **linesPtr = &lines[structLines[i]];

    # Parse struct description
    GetDescription(linesPtr[-1], structs[i].desc);

    # Get struct name: typedef struct name {
    const int TDS_LEN = 15; # length of "typedef struct "
    for (int c = TDS_LEN; c < 64 + TDS_LEN; c++)
    {
        if ((linesPtr[0][c] == '{') || (linesPtr[0][c] == ' '))
        {
            int nameLen = c - TDS_LEN;
            while (linesPtr[0][TDS_LEN + nameLen - 1] == ' ') nameLen--;
            MemoryCopy(structs[i].name, &linesPtr[0][TDS_LEN], nameLen);
            break;
        }
    }

    # Get struct fields and count them -> fields finish with ;
    int l = 1;
    while (linesPtr[l][0] != '}')
    {
        # WARNING: Some structs have empty spaces and comments -> OK, processed
        if ((linesPtr[l][0] != ' ') && (linesPtr[l][0] != '\0'))
        {
            # Scan one field line
            char *fieldLine = linesPtr[l];
            int fieldEndPos = 0;
            while (fieldLine[fieldEndPos] != ';') fieldEndPos++;

            if ((fieldLine[0] != '/') && !IsTextEqual(fieldLine, "struct", 6)) # Field line is not a comment and not a struct declaration
            {
                #printf("Struct field: %s_\n", fieldLine);     # OK!

                # Get struct field type and name
                GetDataTypeAndName(fieldLine, fieldEndPos, structs[i].fieldType[structs[i].fieldCount], structs[i].fieldName[structs[i].fieldCount]);

                # Get the field description
                GetDescription(&fieldLine[fieldEndPos], structs[i].fieldDesc[structs[i].fieldCount]);

                structs[i].fieldCount++;

                # Split field names containing multiple fields (like Matrix)
                int additionalFields = 0;
                int originalIndex = structs[i].fieldCount - 1;
                for (unsigned int c = 0; c < TextLength(structs[i].fieldName[originalIndex]); c++)
                {
                    if (structs[i].fieldName[originalIndex][c] == ',') additionalFields++;
                }

                if (additionalFields > 0)
                {
                    int originalLength = -1;
                    int lastStart;
                    for (unsigned int c = 0; c < TextLength(structs[i].fieldName[originalIndex]) + 1; c++)
                    {
                        char v = structs[i].fieldName[originalIndex][c];
                        bool isEndOfString = (v == '\0');
                        if ((v == ',') || isEndOfString)
                        {
                            if (originalLength == -1)
                            {
                                # Save length of original field name
                                # Don't truncate yet, still needed for copying
                                originalLength = c;
                            }
                            else
                            {
                                # Copy field data from original field
                                int nameLength = c - lastStart;
                                MemoryCopy(structs[i].fieldName[structs[i].fieldCount], &structs[i].fieldName[originalIndex][lastStart], nameLength);
                                MemoryCopy(structs[i].fieldType[structs[i].fieldCount], &structs[i].fieldType[originalIndex][0], TextLength(structs[i].fieldType[originalIndex]));
                                MemoryCopy(structs[i].fieldDesc[structs[i].fieldCount], &structs[i].fieldDesc[originalIndex][0], TextLength(structs[i].fieldDesc[originalIndex]));
                                structs[i].fieldCount++;
                            }
                            if (!isEndOfString)
                            {
                                # Skip comma and spaces
                                c++;
                                while (structs[i].fieldName[originalIndex][c] == ' ') c++;

                                # Save position for next field
                                lastStart = c;
                            }
                        }
                    }
                    # Set length of original field to truncate the first field name
                    structs[i].fieldName[originalIndex][originalLength] = '\0';
                }

                # Split field types containing multiple fields (like MemNode)
                additionalFields = 0;
                originalIndex = structs[i].fieldCount - 1;
                for (unsigned int c = 0; c < TextLength(structs[i].fieldType[originalIndex]); c++)
                {
                    if (structs[i].fieldType[originalIndex][c] == ',') additionalFields++;
                }

                if (additionalFields > 0)
                {
                    # Copy original name to last additional field
                    structs[i].fieldCount += additionalFields;
                    MemoryCopy(structs[i].fieldName[originalIndex + additionalFields], &structs[i].fieldName[originalIndex][0], TextLength(structs[i].fieldName[originalIndex]));

                    # Copy names from type to additional fields
                    int fieldsRemaining = additionalFields;
                    int nameStart = -1;
                    int nameEnd = -1;
                    for (int k = TextLength(structs[i].fieldType[originalIndex]); k > 0; k--)
                    {
                        char v = structs[i].fieldType[originalIndex][k];
                        if ((v == '*') || (v == ' ') || (v == ','))
                        {
                            if (nameEnd != -1) {
                                # Don't copy to last additional field
                                if (fieldsRemaining != additionalFields)
                                {
                                    nameStart = k + 1;
                                    MemoryCopy(structs[i].fieldName[originalIndex + fieldsRemaining], &structs[i].fieldType[originalIndex][nameStart], nameEnd - nameStart + 1);
                                }
                                nameEnd = -1;
                                fieldsRemaining--;
                            }
                        }
                        else if (nameEnd == -1) nameEnd = k;
                    }

                    # Truncate original field type
                    int fieldTypeLength = nameStart;
                    structs[i].fieldType[originalIndex][fieldTypeLength] = '\0';

                    # Set field type and description of additional fields
                    for (int j = 1; j <= additionalFields; j++)
                    {
                        MemoryCopy(structs[i].fieldType[originalIndex + j], &structs[i].fieldType[originalIndex][0], fieldTypeLength);
                        MemoryCopy(structs[i].fieldDesc[originalIndex + j], &structs[i].fieldDesc[originalIndex][0], TextLength(structs[i].fieldDesc[originalIndex]));
                    }
                }
            }
        }

        l++;
    }

    # Move array sizes from name to type
    for (int j = 0; j < structs[i].fieldCount; j++)
    {
        MoveArraySize(structs[i].fieldName[j], structs[i].fieldType[j]);
    }
}
free(structLines);

# Alias info data
aliases = (AliasInfo *)calloc(MAX_ALIASES_TO_PARSE, sizeof(AliasInfo));

for (int i = 0; i < aliasCount; i++)
{
    # Description from previous line
    GetDescription(lines[aliasLines[i] - 1], aliases[i].desc);

    char *linePtr = lines[aliasLines[i]];

    # Skip "typedef "
    int c = 8;

    # Type
    int typeStart = c;
    while(linePtr[c] != ' ') c++;
    int typeLen = c - typeStart;
    MemoryCopy(aliases[i].type, &linePtr[typeStart], typeLen);

    # Skip space
    c++;

    # Name
    int nameStart = c;
    while(linePtr[c] != ';') c++;
    int nameLen = c - nameStart;
    MemoryCopy(aliases[i].name, &linePtr[nameStart], nameLen);

    # Description
    GetDescription(&linePtr[c], aliases[i].desc);
}
free(aliasLines);

# Enum info data
enums = (EnumInfo *)calloc(MAX_ENUMS_TO_PARSE, sizeof(EnumInfo));

for (int i = 0; i < enumCount; i++)
{

    # Parse enum description
    # NOTE: This is not necessarily from the line immediately before,
    # some of the enums have extra lines between the "description"
    # and the typedef enum
    for (int j = enumLines[i] - 1; j > 0; j--)
    {
        char *linePtr = lines[j];
        if ((linePtr[0] != '/') || (linePtr[2] != ' '))
        {
            GetDescription(&lines[j + 1][0], enums[i].desc);
            break;
        }
    }

    for (int j = 1; j < MAX_ENUM_VALUES*2; j++)   # Maximum number of lines following enum first line
    {
        char *linePtr = lines[enumLines[i] + j];

        if ((linePtr[0] >= 'A') && (linePtr[0] <= 'Z'))
        {
            # Parse enum value line, possible options:
            #ENUM_VALUE_NAME,
            #ENUM_VALUE_NAME
            #ENUM_VALUE_NAME     = 99
            #ENUM_VALUE_NAME     = 99,
            #ENUM_VALUE_NAME     = 0x00000040,   # Value description

            # We start reading the value name
            int c = 0;
            while ((linePtr[c] != ',') &&
                    (linePtr[c] != ' ') &&
                    (linePtr[c] != '=') &&
                    (linePtr[c] != '\0'))
            {
                enums[i].valueName[enums[i].valueCount][c] = linePtr[c];
                c++;
            }

            # After the name we can have:
            #  '='  -> value is provided
            #  ','  -> value is equal to previous + 1, there could be a description if not '\0'
            #  ' '  -> value is equal to previous + 1, there could be a description if not '\0'
            #  '\0' -> value is equal to previous + 1

            # Let's start checking if the line is not finished
            if ((linePtr[c] != ',') && (linePtr[c] != '\0'))
            {
                # Two options:
                #  '='  -> value is provided
                #  ' '  -> value is equal to previous + 1, there could be a description if not '\0'
                bool foundValue = false;
                while ((linePtr[c] != '\0') && (linePtr[c] != '/'))
                {
                    if (linePtr[c] == '=')
                    {
                        foundValue = true;
                        break;
                    }
                    c++;
                }

                if (foundValue)
                {
                    if (linePtr[c + 1] == ' ') c += 2;
                    else c++;

                    # Parse integer value
                    int n = 0;
                    char integer[16] = { 0 };

                    while ((linePtr[c] != ',') && (linePtr[c] != ' ') && (linePtr[c] != '\0'))
                    {
                        integer[n] = linePtr[c];
                        c++; n++;
                    }

                    if (integer[1] == 'x') enums[i].valueInteger[enums[i].valueCount] = (int)strtol(integer, NULL, 16);
                    else enums[i].valueInteger[enums[i].valueCount] = atoi(integer);
                }
                else enums[i].valueInteger[enums[i].valueCount] = (enums[i].valueInteger[enums[i].valueCount - 1] + 1);
            }
            else enums[i].valueInteger[enums[i].valueCount] = (enums[i].valueInteger[enums[i].valueCount - 1] + 1);

            # Parse value description
            GetDescription(&linePtr[c], enums[i].valueDesc[enums[i].valueCount]);

            enums[i].valueCount++;
        }
        else if (linePtr[0] == '}')
        {
            # Get enum name from typedef
            int c = 0;
            while (linePtr[2 + c] != ';')
            {
                enums[i].name[c] = linePtr[2 + c];
                c++;
            }

            break;  # Enum ended, break for() loop
        }
    }
}
free(enumLines);

# Callback info data
callbacks = (FunctionInfo *)calloc(MAX_CALLBACKS_TO_PARSE, sizeof(FunctionInfo));

for (int i = 0; i < callbackCount; i++)
{
    char *linePtr = lines[callbackLines[i]];

    # Skip "typedef "
    unsigned int c = 8;

    # Return type
    int retTypeStart = c;
    while(linePtr[c] != '(') c++;
    int retTypeLen = c - retTypeStart;
    while(linePtr[retTypeStart + retTypeLen - 1] == ' ') retTypeLen--;
    MemoryCopy(callbacks[i].retType, &linePtr[retTypeStart], retTypeLen);

    # Skip "(*"
    c += 2;

    # Name
    int nameStart = c;
    while(linePtr[c] != ')') c++;
    int nameLen = c - nameStart;
    MemoryCopy(callbacks[i].name, &linePtr[nameStart], nameLen);

    # Skip ")("
    c += 2;

    # Params
    int paramStart = c;
    for (; c < MAX_LINE_LENGTH; c++)
    {
        if ((linePtr[c] == ',') || (linePtr[c] == ')'))
        {
            # Get parameter type + name, extract info
            int paramLen = c - paramStart;
            GetDataTypeAndName(&linePtr[paramStart], paramLen, callbacks[i].paramType[callbacks[i].paramCount], callbacks[i].paramName[callbacks[i].paramCount]);
            callbacks[i].paramCount++;
            paramStart = c + 1;
            while(linePtr[paramStart] == ' ') paramStart++;
        }
        if (linePtr[c] == ')') break;
    }

    # Description
    GetDescription(&linePtr[c], callbacks[i].desc);

    # Move array sizes from name to type
    for (int j = 0; j < callbacks[i].paramCount; j++)
    {
        MoveArraySize(callbacks[i].paramName[j], callbacks[i].paramType[j]);
    }
}
free(callbackLines);

# Functions info data
funcs = (FunctionInfo *)calloc(MAX_FUNCS_TO_PARSE, sizeof(FunctionInfo));

for (int i = 0; i < funcCount; i++)
{
    char *linePtr = lines[funcLines[i]];

    int funcParamsStart = 0;
    int funcEnd = 0;

    # Get return type and function name from func line
    for (int c = 0; (c < MAX_LINE_LENGTH) && (linePtr[c] != '\n'); c++)
    {
        if (linePtr[c] == '(')     # Starts function parameters
        {
            funcParamsStart = c + 1;

            # At this point we have function return type and function name
            char funcRetTypeName[128] = { 0 };
            int dc = TextLength(apiDefine) + 1;
            int funcRetTypeNameLen = c - dc;     # Substract `define` ("RLAPI " for raylib.h)
            MemoryCopy(funcRetTypeName, &linePtr[dc], funcRetTypeNameLen);

            GetDataTypeAndName(funcRetTypeName, funcRetTypeNameLen, funcs[i].retType, funcs[i].name);
            break;
        }
    }

    # Get parameters from func line
    for (int c = funcParamsStart; c < MAX_LINE_LENGTH; c++)
    {
        if (linePtr[c] == ',')     # Starts function parameters
        {
            # Get parameter type + name, extract info
            char funcParamTypeName[128] = { 0 };
            int funcParamTypeNameLen = c - funcParamsStart;
            MemoryCopy(funcParamTypeName, &linePtr[funcParamsStart], funcParamTypeNameLen);

            GetDataTypeAndName(funcParamTypeName, funcParamTypeNameLen, funcs[i].paramType[funcs[i].paramCount], funcs[i].paramName[funcs[i].paramCount]);

            funcParamsStart = c + 1;
            if (linePtr[c + 1] == ' ') funcParamsStart += 1;
            funcs[i].paramCount++;      # Move to next parameter
        }
        else if (linePtr[c] == ')')
        {
            funcEnd = c + 2;

            # Check if previous word is void
            if ((linePtr[c - 4] == 'v') && (linePtr[c - 3] == 'o') && (linePtr[c - 2] == 'i') && (linePtr[c - 1] == 'd')) break;

            # Get parameter type + name, extract info
            char funcParamTypeName[128] = { 0 };
            int funcParamTypeNameLen = c - funcParamsStart;
            MemoryCopy(funcParamTypeName, &linePtr[funcParamsStart], funcParamTypeNameLen);

            GetDataTypeAndName(funcParamTypeName, funcParamTypeNameLen, funcs[i].paramType[funcs[i].paramCount], funcs[i].paramName[funcs[i].paramCount]);

            funcs[i].paramCount++;      # Move to next parameter
            break;
        }
    }

    # Get function description
    GetDescription(&linePtr[funcEnd], funcs[i].desc);

    # Move array sizes from name to type
    for (int j = 0; j < funcs[i].paramCount; j++)
    {
        MoveArraySize(funcs[i].paramName[j], funcs[i].paramType[j]);
    }
}
free(funcLines);

for (int i = 0; i < linesCount; i++) free(lines[i]);
free(lines);

# At this point, all raylib data has been parsed!
#----------------------------------------------------------------------------------
# defines[]   -> We have all the defines decomposed into pieces for further analysis
# structs[]   -> We have all the structs decomposed into pieces for further analysis
# aliases[]   -> We have all the aliases decomposed into pieces for further analysis
# enums[]     -> We have all the enums decomposed into pieces for further analysis
# callbacks[] -> We have all the callbacks decomposed into pieces for further analysis
# funcs[]     -> We have all the functions decomposed into pieces for further analysis
•Out""
•Out"Input file:       "∾inFileName
•Out"Output file:      "∾outFileName

ExportParsedData(outFileName);