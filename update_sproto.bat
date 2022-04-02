@echo off  

set source_dir=%cd%\..\JyQipai_server
set target_dir=%cd%

cd %source_dir%
::git pull
echo.

set source_dir=%cd%\skynet\game\protocol\
set target_dir=%target_dir%\1_code\Assets\Game\Sproto

echo source_dir:%source_dir%
echo target_dir:%target_dir%

echo.

::copy %source_dir%\proto_both.sproto %target_dir%\proto_both.txt
::copy %source_dir%\proto_c2s.sproto %target_dir%\proto_c2s.txt
::copy %source_dir%\proto_s2c.sproto %target_dir%\proto_s2c.txt

copy /y %source_dir%\whole_proto_c2s.txt %target_dir%\whole_proto_c2s.txt
copy /y %source_dir%\whole_proto_s2c.txt %target_dir%\whole_proto_s2c.txt

::copy /y %source_dir%\*.* %target_dir%\*.*.txt

pause 

