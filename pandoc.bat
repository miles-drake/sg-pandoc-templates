@echo off

call :version
call :set_defaults
call :assert_path_diff %invoke_path% %batch_path%
call :read_params %1 %2 %3 %4 %5 %6 %7 %8 %9
call :set_param pandoc_fullpath input_path output_path output_name toc_depth
call :build_input_fullpaths %input_path%
call :create_dir %output_path%
call :pandoc_build_and_run docx pdf
call :end

: version
  echo Scottish Government -- Analytical Data Management Team
  echo Use Pandoc to convert documentation written in plain text to other formats
  echo Output formats conform to SG's accessibility guidelines
  echo https://github.com/miles-drake/sg-pandoc-templates
  echo Last updated: 2021-10-10 & echo.
  exit /b 0

: set_defaults
  for %%X in (.) do (
    set invoke_path=%%~fX
    set invoke_dirname=%%~nX
  )
  set batch_path=%~dp0
  set batch_path=%batch_path:~0,-1%
  set default_input_path=%invoke_path%
  set default_output_name=%invoke_dirname%
  set default_output_path=%invoke_path%
  set default_pandoc_fullpath=C:\Program Files\Pandoc\pandoc.exe
  :: _sp defines the spacer / indent string used in some echos
  set _sp=  
  exit /b 0

: assert_path_diff
  if %~1==%~2 if exist "%~1\pandoc.bat" (
    echo [WARNING] The current working directory may be this batch file's directory.
    echo To invoke this batch file from the same directory as a Windows shortcut, empty the shortcut's "Starts in" property. & echo.
    echo Invoke path: & echo %_sp%%~1
    echo Batch file path: & echo %_sp%%~2 & echo.
    pause & echo.
  )
  exit /b 0

: read_params
  if not %1.==. (
    if not "%__value%"=="" (
      if not "%__value:~0,1%"=="-" (
        endlocal & goto read_params
      )
        endlocal & set %__value:~1%=%~1
    ) else (
        setlocal & set __value=%~1
    )
    shift
    goto read_params
  )
  exit /b 0

: set_param
  if %~1.==. (
    echo.
    exit /b 0
  )
  if not %~1==pandoc_fullpath if not %~1==input_path if not %~1==output_path if not %~1==output_name if not %~1==toc_depth (
    echo [WARNING] %~1 is not a recognised parameter.
    shift
    goto :set_param
  )
  setlocal
  set _name=%~1
  if %_name%==pandoc_fullpath (
    set _echo=Pandoc executable full path
    set _default=%default_pandoc_fullpath%
    set _arg=p
    set _param=%p%
  )
  if %_name%==input_path (
    set _echo=Input path
    set _default=%default_input_path%
    set _arg=i
    set _param=%i%
  )
  if %_name%==output_path (
    set _echo=Output path
    set _default=%default_output_path%
    set _arg=o
    set _param=%o%
  )
  if %_name%==output_name (
    set _echo=Output file name
    set _default=%default_output_name%
    set _arg=n
    set _param=%n%
  )
  if %_name%==toc_depth (
    set _echo=Table of contents depth
    set _default=1
    set _arg=t
    set _param=%t%
  )
  set _value=%_param%
  :: If parameter is blank, set the default value
  if %_value%.==. (
    set _echo=%_echo% [default] [-%_arg%=...]
    set _value=%_default%
  )
  :: Relative to absolute path conversion
  :: If the parameter is a path, and the second character is not a colon,
  :: convert the assumed relative path to an absolute full path
  set _name=%_name%____
  set _value=%_value%__
  if %_name:~-8%==path____ if not %_value:~1,1%==: (
    set _value=%invoke_path%\%_param%__
  )
  set _name=%_name:~0,-4%
  set _value=%_value:~0,-2%
  :: END Relative to absolute path conversion
  set _echo=%_echo%:
  echo %_echo% & echo %_sp%%_value%
  :: Set integer flag for toc_depth
  if %_name%==toc_depth (
    endlocal & set /A %_name%=%_value%
  ) else (
    endlocal & set %_name%=%_value%
  )
  shift
  goto :set_param
  exit /b 0

: build_input_fullpaths
  echo Input files - Files will be parsed in the following order:
  setlocal
  for /r %~1 %%X in (*.yaml *.yml) do call :c_fullpaths %%X
  endlocal & set input_fullpaths_metadata=%_all_fullpaths%
  setlocal
  for /r %~1 %%X in (*.md *.txt) do call :c_fullpaths %%X
  endlocal & set input_fullpaths_text=%_all_fullpaths%
  echo.
  exit /b 0

: c_fullpaths
  set _fullpath=%~f1
  echo %_sp%%_fullpath%
  set _all_fullpaths=%_all_fullpaths% "%_fullpath%"
  exit /b 0

: create_dir
  if not exist %~1 mkdir %~1
  exit /b 0

: pandoc_build_and_run
  :: Input parameters should be file extensions, e.g. docx or pdf
  if %~1.==. exit /b 0
  call :build_arg_input %~1
  call :build_arg_output %~1
  call :build_arg_engine %~1
  call :build_arg_aes %~1
  call :run_pandoc %~1
  shift
  goto pandoc_build_and_run
  exit /b 0

: build_arg_input
  if %~1==pdf set arg_input="%batch_path%\latex.yaml"
  set arg_input=%arg_input% %input_fullpaths_metadata%
  if %toc_depth% gtr 0 (
    set arg_input=%arg_input% "%batch_path%\page-break-%~1.txt"
  )
  set arg_input=%arg_input% %input_fullpaths_text%
  exit /b 0

: build_arg_output
  set arg_output=-o "%output_path%\%output_name%.%~1"
  exit /b 0

: build_arg_engine
  if %~1==docx set arg_engine=--reference-doc="%batch_path%\template.docx"
  if %~1==pdf set arg_engine=--pdf-engine=xelatex
  exit /b 0

: build_arg_aes
  set arg_aes=--number-sections
  if %toc_depth% gtr 0 (
    set arg_aes=--toc --toc-depth=%toc_depth%
  )
  exit /b 0

: run_pandoc
  echo Converting to %~1 ... & echo %_sp%%arg_output:~4,-1%
  "%pandoc_fullpath%" %arg_input% %arg_output% %arg_engine% %arg_aes%
  echo Done. & echo.
  exit /b 0

: end
  echo End of batch file. & echo.
  pause
  exit /b %errorlevel%
