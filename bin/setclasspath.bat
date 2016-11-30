@echo off
rem Licensed to the Apache Software Foundation (ASF) under one or more
rem contributor license agreements.  See the NOTICE file distributed with
rem this work for additional information regarding copyright ownership.
rem The ASF licenses this file to You under the Apache License, Version 2.0
rem (the "License"); you may not use this file except in compliance with
rem the License.  You may obtain a copy of the License at
rem
rem     http://www.apache.org/licenses/LICENSE-2.0
rem
rem Unless required by applicable law or agreed to in writing, software
rem distributed under the License is distributed on an "AS IS" BASIS,
rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
rem See the License for the specific language governing permissions and
rem limitations under the License.

rem ---------------------------------------------------------------------------
rem Set JAVA_HOME or JRE_HOME if not already set, ensure any provided settings
rem are valid and consistent with the selected start-up options and set up the
rem endorsed directory.
rem ---------------------------------------------------------------------------

rem Make sure prerequisite environment variables are set

rem ---------------------------------------------------------------------------
rem 这个脚本主要就是设置了以下几个变量:
rem 1. JAVA_HOME
rem 2. JRE_HOME
rem 3. JAVA_ENDORSED_DIRS = %CATALINA_HOME%\endorsed
rem 4. _RUNJAVA = %JRE_HOME%\bin\java.exe
rem 5. _RUNJDB = %JAVA_HOME%\bin\jdb.exe
rem ---------------------------------------------------------------------------


rem In debug mode we need a real JDK (JAVA_HOME)
if ""%1"" == ""debug"" goto needJavaHome

rem Otherwise either JRE or JDK are fine
rem 除了 debug 之后, JRE 或者 JDK 都是可以的

rem 如果配置了 JRE_HOME, 就跳转到 gotJreHome
if not "%JRE_HOME%" == "" goto gotJreHome

rem 如果配置了 JAVA_HOME, 就跳转到 gotJavaHome
if not "%JAVA_HOME%" == "" goto gotJavaHome

echo Neither the JAVA_HOME nor the JRE_HOME environment variable is defined
echo At least one of these environment variable is needed to run this program
goto exit

:needJavaHome
rem Check if we have a usable JDK
if "%JAVA_HOME%" == "" goto noJavaHome
if not exist "%JAVA_HOME%\bin\java.exe" goto noJavaHome
if not exist "%JAVA_HOME%\bin\javaw.exe" goto noJavaHome
if not exist "%JAVA_HOME%\bin\jdb.exe" goto noJavaHome
if not exist "%JAVA_HOME%\bin\javac.exe" goto noJavaHome
set "JRE_HOME=%JAVA_HOME%"
goto okJava

:noJavaHome
echo The JAVA_HOME environment variable is not defined correctly.
echo It is needed to run this program in debug mode.
echo NB: JAVA_HOME should point to a JDK not a JRE.
goto exit

:gotJavaHome
rem No JRE given, use JAVA_HOME as JRE_HOME
rem 没有配置 JER, JRE_HOME 就引用 JAVA_HOME 的值
set "JRE_HOME=%JAVA_HOME%"

:gotJreHome
rem Check if we have a usable JRE
rem 因为上面引用了 JAVA_HOME 的值, 如果我们配置好了 JAVA_HOME 环境变量, 那么这里是找得到 java 和 javaw 的
if not exist "%JRE_HOME%\bin\java.exe" goto noJreHome
if not exist "%JRE_HOME%\bin\javaw.exe" goto noJreHome
goto okJava

:noJreHome
rem Needed at least a JRE
echo The JRE_HOME environment variable is not defined correctly
echo This environment variable is needed to run this program
goto exit

:okJava
rem Don't override the endorsed dir if the user has set it previously(如果用户以前设置过, 不要覆盖已签名的目录)
rem 通常情况下这个变量是没有配置的
if not "%JAVA_ENDORSED_DIRS%" == "" goto gotEndorseddir

rem 设置 JAVA_ENDORSED_DIRS 环境变量的值为 %CATALINA_HOME%\endorsed
rem 默认情况下是没有这个目录的
set "JAVA_ENDORSED_DIRS=%CATALINA_HOME%\endorsed"

:gotEndorseddir
rem Don't override _RUNJAVA if the user has set it previously
rem 通常这个变量也是没有配置的
if not "%_RUNJAVA%" == "" goto gotRunJava

rem Set standard command for invoking Java.
rem Also note the quoting as JRE_HOME may contain spaces.
rem 设置执行 Java 的命令 java.exe
set _RUNJAVA="%JRE_HOME%\bin\java.exe"

:gotRunJava
rem Don't override _RUNJDB if the user has set it previously
rem Also note the quoting as JAVA_HOME may contain spaces.
if not "%_RUNJDB%" == "" goto gotRunJdb
rem 设置 _RUNJDB 环境变量指向 jdb.exe
set _RUNJDB="%JAVA_HOME%\bin\jdb.exe"
:gotRunJdb

goto end

:exit
exit /b 1

:end
exit /b 0
