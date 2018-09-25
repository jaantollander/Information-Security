@echo off
setlocal EnableDelayedExpansion
set OUTFILE=submission.txt

set GROUP=Project2018
set GROUP_USERS=Alice Bob
set NONGROUP_USERS=Carol
set USERS=%GROUP_USERS% %NONGROUP_USERS%

set BASE_FOLDER=C:\
set ASSIGNMENT_FOLDER=%BASE_FOLDER%project
set CONFIDENTIAL_FOLDER=%ASSIGNMENT_FOLDER%\confidential

set GRPOBJS=%ASSIGNMENT_FOLDER% %ASSIGNMENT_FOLDER%\sprint.txt
set CNFOBJS=%CONFIDENTIAL_FOLDER% %CONFIDENTIAL_FOLDER%\jokes.txt
set ALLOBJS=%GRPOBJS% %CNFOBJS%

rem Check whether the group exists
net localgroup | find "%GROUP%" > nul || (echo Group %GROUP% doesn't exist & goto:eof)

rem Check whether all users exist
for %%u in (%USERS%) do (
  net users | find "%%u" > nul || (echo User %%u doesn't exist & goto:eof)
)

rem Check group members
for %%u in (%GROUP_USERS%) do (
  net localgroup %GROUP% | find "%%u" > nul || (echo User %%u must be a member of group %GROUP% & goto:eof)
)

rem Check non-group users
for %%u in (%NONGROUP_USERS%) do (
  net localgroup %GROUP% | find "%%u" > nul && (echo User %%u must not be a member of group %GROUP% & goto:eof)
)

rem Check whether files and folders exist
for %%o in (%ALLOBJS%) do (
  if not exist %%o (
    echo %%o doesn't exist
    goto:eof
  )
)

rem Write file
echo {> %OUTFILE%

rem Access control information
for %%o in (%ALLOBJS%) do (
  set data=
  for /f "delims=" %%l in ('icacls %%o ^| findstr /vb "Successfully processed"') do (
  set t=
    for %%u in (%%l) do (
      if not %%u==%%o if not %%u==NT (
    set t=!t!%%u
      )
    )
  set data=!data!"!t!",
  )
  set data=!data:~0,-1!
  echo   "%%o":[!data!],>> %OUTFILE%
)

rem Username of the current user
rem echo   "username":"%USERNAME%",>> %OUTFILE%

rem Members of the project group
set data=
for /f "tokens=* skip=6" %%u in ('net localgroup %GROUP% ^| findstr /vb "The command completed successfully"') do (
  set data=!data!"%%u",
)
set data=!data:~0,-1!
echo   "%GROUP%":[!data!],>> %OUTFILE%

rem Members of the Administrators group
set admingroup=
for /f "tokens=* skip=1" %%i in ('wmic group where "SID='S-1-5-32-544'" get name') do (
  set admingroup=!admingroup!%%i
)

set data=
for /f "tokens=* skip=6" %%u in ('net localgroup !admingroup! ^| findstr /vb "The command completed successfully"') do (
  set data=!data!"%%u",
)
set data=!data:~0,-1!
echo   "admin":[!data!]>> %OUTFILE%

echo }>> %OUTFILE%

echo Submit content of %OUTFILE% as your solution.

endlocal