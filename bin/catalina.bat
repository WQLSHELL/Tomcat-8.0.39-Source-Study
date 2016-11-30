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
rem Start/Stop Script for the CATALINA Server
rem
rem Environment Variable Prerequisites
rem
rem   Do not set the variables in this script. Instead put them into a script
rem   setenv.bat in CATALINA_BASE/bin to keep your customizations separate.
rem
rem   WHEN RUNNING TOMCAT AS A WINDOWS SERVICE:
rem   Note that the environment variables that affect the behavior of this
rem   script will have no effect at all on Windows Services. As such, any
rem   local customizations made in a CATALINA_BASE/bin/setenv.bat script
rem   will also have no effect on Tomcat when launched as a Windows Service.
rem   The configuration that controls Windows Services is stored in the Windows
rem   Registry, and is most conveniently maintained using the "tomcatXw.exe"
rem   maintenance utility, where "X" is the major version of Tomcat you are
rem   running.
rem
rem   CATALINA_HOME   May point at your Catalina "build" directory.
rem
rem   CATALINA_BASE   (Optional) Base directory for resolving dynamic portions
rem                   of a Catalina installation.  If not present, resolves to
rem                   the same directory that CATALINA_HOME points to.
rem
rem   CATALINA_OPTS   (Optional) Java runtime options used when the "start",
rem                   "run" or "debug" command is executed.
rem                   Include here and not in JAVA_OPTS all options, that should
rem                   only be used by Tomcat itself, not by the stop process,
rem                   the version command etc.
rem                   Examples are heap size, GC logging, JMX ports etc.
rem
rem   CATALINA_TMPDIR (Optional) Directory path location of temporary directory
rem                   the JVM should use (java.io.tmpdir).  Defaults to
rem                   %CATALINA_BASE%\temp.
rem
rem   JAVA_HOME       Must point at your Java Development Kit installation.
rem                   Required to run the with the "debug" argument.
rem
rem   JRE_HOME        Must point at your Java Runtime installation.
rem                   Defaults to JAVA_HOME if empty. If JRE_HOME and JAVA_HOME
rem                   are both set, JRE_HOME is used.
rem
rem   JAVA_OPTS       (Optional) Java runtime options used when any command
rem                   is executed.
rem                   Include here and not in CATALINA_OPTS all options, that
rem                   should be used by Tomcat and also by the stop process,
rem                   the version command etc.
rem                   Most options should go into CATALINA_OPTS.
rem
rem   JAVA_ENDORSED_DIRS (Optional) Lists of of semi-colon separated directories
rem                   containing some jars in order to allow replacement of APIs
rem                   created outside of the JCP (i.e. DOM and SAX from W3C).
rem                   It can also be used to update the XML parser implementation.
rem                   Defaults to $CATALINA_HOME/endorsed.
rem
rem   JPDA_TRANSPORT  (Optional) JPDA transport used when the "jpda start"
rem                   command is executed. The default is "dt_socket".
rem
rem   JPDA_ADDRESS    (Optional) Java runtime options used when the "jpda start"
rem                   command is executed. The default is localhost:8000.
rem
rem   JPDA_SUSPEND    (Optional) Java runtime options used when the "jpda start"
rem                   command is executed. Specifies whether JVM should suspend
rem                   execution immediately after startup. Default is "n".
rem
rem   JPDA_OPTS       (Optional) Java runtime options used when the "jpda start"
rem                   command is executed. If used, JPDA_TRANSPORT, JPDA_ADDRESS,
rem                   and JPDA_SUSPEND are ignored. Thus, all required jpda
rem                   options MUST be specified. The default is:
rem
rem                   -agentlib:jdwp=transport=%JPDA_TRANSPORT%,
rem                       address=%JPDA_ADDRESS%,server=y,suspend=%JPDA_SUSPEND%
rem
rem   JSSE_OPTS       (Optional) Java runtime options used to control the TLS
rem                   implementation when JSSE is used. Default is:
rem                   "-Djdk.tls.ephemeralDHKeySize=2048"
rem
rem   LOGGING_CONFIG  (Optional) Override Tomcat's logging config file
rem                   Example (all one line)
rem                   set LOGGING_CONFIG="-Djava.util.logging.config.file=%CATALINA_BASE%\conf\logging.properties"
rem
rem   LOGGING_MANAGER (Optional) Override Tomcat's logging manager
rem                   Example (all one line)
rem                   set LOGGING_MANAGER="-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager"
rem
rem   TITLE           (Optional) Specify the title of Tomcat window. The default
rem                   TITLE is Tomcat if it's not specified.
rem                   Example (all one line)
rem                   set TITLE=Tomcat.Cluster#1.Server#1 [%DATE% %TIME%]
rem ---------------------------------------------------------------------------

setlocal

rem Suppress Terminate batch job on CTRL+C
rem 禁止使用 CTRL+C 终止批处理任务

rem 调用本脚本的命令为: ./apache-tomcat-x.x.xx/bin/catalina.bat start
rem 所以 "%1": start, 直接跳转到 mainEntry 标签处

rem -------------------------------------- catalina.bat run 启动 Tomcat 分析------------开始
rem 通常情况下, 我们都是通过 startup.bat 脚本来启动 Tomcat 的, 所以传过来的参数无疑是 start
rem 通过分析 startup.bat 我们知道它其实找到 catalina.bat 脚本执行它, 并传递启动参数
rem 有经验的人也许会直接通过 catalina.bat run 来启动 Tomcat, 所以就产生了这种情况
if not ""%1"" == ""run"" goto mainEntry

rem TEMP 这个变量是读取的系统中的变量
if "%TEMP%" == "" goto mainEntry

rem %~nx0 就是获取文件名和其扩展名(catalina.bat)
rem 判断是否在 TEMP 变量的目录下存在 catalina.bat.run 文件
rem 等下次回调自己的时候, 这里这个 catalina.bat.run 文件是存在的. 所以进入正常的启动过程
if exist "%TEMP%\%~nx0.run" goto mainEntry

rem 如果不存在这个文件, 那么就新建一个, 并写入 Y
echo Y>"%TEMP%\%~nx0.run"

rem 再一次判断是否有 catalina.bat.run 这个文件.
if not exist "%TEMP%\%~nx0.run" goto mainEntry

rem 同样再次写 Y 到 TEMP 目录下的 catalina.bat.Y 文件中, 如果不存在则创建一个
echo Y>"%TEMP%\%~nx0.Y"

rem %~f0 表示当前批处理的绝对路径,去掉引号的完整路径
rem %* 表示命令行传过来的参数, %1 表示第一个参数, %* 表示所有参数
rem 程序会一直调用自己. 这里其实就是回调自己, 启动 Tomcat.
call "%~f0" %* <"%TEMP%\%~nx0.Y"

rem 适用返回的 errorLevel
set RETVAL=%ERRORLEVEL%

rem 静默删除 TEMP 目录下的东西
rem >NUL 将输出输出到 NUL 中, 也就是有错误你也看不到
rem 2>&1  2:错误输出, &1:标准输出, 意思就是将错误输出重定向到标准输出中
rem >NUL 2>&1  先将错误输出重定向到标准输出中, 然后再重定向到 NUL 中,
del /Q "%TEMP%\%~nx0.Y" >NUL 2>&1
rem 退出当前批处理, /B 指定退出时的编号, 把 RETVAL 最为 退出码, 也就是 catalina.bat start 的退出码
exit /B %RETVAL%
rem -------------------------------------- catalina.bat run 启动 Tomcat 分析------------结束

rem -------------------------------------- 正常启动 Tomcat 分析------------开始
rem 如果是通过 startup.bat 启动的话, 直接跳转到这里
:mainEntry

rem 同样会删除 TEMP 目录下的 catalina.bat.run 文件
del /Q "%TEMP%\%~nx0.run" >NUL 2>&1

rem --------------------------设置 CATALINA_HOME 环境变量-------------------------
rem 159行 到 166行 与 startup.bat 中的内容是一样的, 就不说了
rem 这段代码就是设置 CATALINA_HOME 变量
set "CURRENT_DIR=%cd%"
if not "%CATALINA_HOME%" == "" goto gotHome
set "CATALINA_HOME=%CURRENT_DIR%"
if exist "%CATALINA_HOME%\bin\catalina.bat" goto okHome
cd ..
set "CATALINA_HOME=%cd%"
cd "%CURRENT_DIR%"

rem --------------------------设置 CATALINA_BASE 环境变量-------------------------
:gotHome
rem 判断一下目录是否正确
if exist "%CATALINA_HOME%\bin\catalina.bat" goto okHome
echo The CATALINA_HOME environment variable is not defined correctly
echo This environment variable is needed to run this program
goto end

:okHome
rem 如果 CATALINA_BASE 没有定义, 那么直接复用 CATALINA_HOME 的值
if not "%CATALINA_BASE%" == "" goto gotBase
set "CATALINA_BASE=%CATALINA_HOME%"

rem -------------------- 检查 CATALINA_HOME 和 CATALINA_BASE 变量的正确性 ---------
:gotBase
rem 确保 CATALINA_HOME 和 CATALINA_BASE 都不包含着分号(;)
if "%CATALINA_HOME%" == "%CATALINA_HOME:;=%" goto homeNoSemicolon
echo Using CATALINA_HOME:   "%CATALINA_HOME%"
echo Unable to start as CATALINA_HOME contains a semicolon (;) character
goto end

:homeNoSemicolon
if "%CATALINA_BASE%" == "%CATALINA_BASE:;=%" goto baseNoSemicolon
echo Using CATALINA_BASE:   "%CATALINA_BASE%"
echo Unable to start as CATALINA_BASE contains a semicolon (;) character
goto end

:baseNoSemicolon
rem Ensure that any user defined CLASSPATH variables are not used on startup,
rem but allow them to be specified in setenv.bat, in rare case when it is needed.


rem ------------------------------ 设置 CLASSPATH 环境变量 -----------------------
rem 开始为启动设置环境变量值
set CLASSPATH=

rem 默认情况下 BASE 目录下是没有 setenv.bat 这个脚本的
if not exist "%CATALINA_BASE%\bin\setenv.bat" goto checkSetenvHome
call "%CATALINA_BASE%\bin\setenv.bat"
goto setenvDone

:checkSetenvHome
rem 默认情况下 HOME 下也是没有的
if exist "%CATALINA_HOME%\bin\setenv.bat" call "%CATALINA_HOME%\bin\setenv.bat"
:setenvDone

rem ------------------------------ 设置 JAVA 相关的环境变量 ----------------------
rem 通常情况下 HOME 目录下是存在 setclasspath.bat 这个脚本的
if exist "%CATALINA_HOME%\bin\setclasspath.bat" goto okSetclasspath

rem 如果不存在直接停止启动 Tomcat
echo Cannot find "%CATALINA_HOME%\bin\setclasspath.bat"
echo This file is needed to run this program
goto end

:okSetclasspath
rem 调用这个脚本进行 Java 环境变量的设置, 并把 start 这个参数传进去, 我们进入这个脚本看代码
rem 传进去参数, 主要是判断当前是否是 debug 模式
call "%CATALINA_HOME%\bin\setclasspath.bat" %1

rem 如果上面命令执行出错, 直接停止 Tomcat 的启动
if errorlevel 1 goto end


rem Add on extra jar file to CLASSPATH( 添加其它的 jar 包到 CLASSPATH 中 )
rem Note that there are no quotes as we do not want to introduce random quotes into the CLASSPATH

rem ------------------------------ 设置 CLASSPATH 环境变量 -----------------------
if "%CLASSPATH%" == "" goto emptyClasspath
rem 给其末尾加一个分号, 防止我们配置的时候, 因为没有加分号, 出错. 想的真周到!
set "CLASSPATH=%CLASSPATH%;"

:emptyClasspath
rem ------------------------------ 把 bootstrap.jar 加入到 CLASSPATH 中 ----------
set "CLASSPATH=%CLASSPATH%%CATALINA_HOME%\bin\bootstrap.jar"

rem ---------------------------- 设置 CATALINA_TMPDIR 变量 -----------------------
if not "%CATALINA_TMPDIR%" == "" goto gotTmpdir
rem 如果没有配置 CATALINA_TMPDIR 环境变量, 则用 Tomcat 地下的 temp 目录.
set "CATALINA_TMPDIR=%CATALINA_BASE%\temp"
:gotTmpdir

rem ------------------------------ 把 tomcat-juli.jar 加入到 CLASSPATH 中 ----------
rem tomcat-juli.jar can be over-ridden per instance
if not exist "%CATALINA_BASE%\bin\tomcat-juli.jar" goto juliClasspathHome
set "CLASSPATH=%CLASSPATH%;%CATALINA_BASE%\bin\tomcat-juli.jar"
goto juliClasspathDone
:juliClasspathHome
set "CLASSPATH=%CLASSPATH%;%CATALINA_HOME%\bin\tomcat-juli.jar"
:juliClasspathDone

rem ----------------- 这个参数( jdk.tls.ephemeralDHKeySize )的作用不明白 -------------
rem 设置 JSSE_OPTS = -Djdk.tls.ephemeralDHKeySize=2048
if not "%JSSE_OPTS%" == "" goto gotJsseOpts
set JSSE_OPTS="-Djdk.tls.ephemeralDHKeySize=2048"
:gotJsseOpts

rem ------------------ 设置 JAVA_OPTS 参数 ---------------------------- 开始

rem 设置 JAVA_OPTS = -Djdk.tls.ephemeralDHKeySize=2048
set "JAVA_OPTS=%JAVA_OPTS% %JSSE_OPTS%"

rem Register custom URL handlers
rem Do this here so custom URL handles (specifically 'war:...') can be used in the security policy
rem 给 JAVA_OPTS 变量加上 -Djava.protocol.handler.pkgs=org.apache.catalina.webresources
set "JAVA_OPTS=%JAVA_OPTS% -Djava.protocol.handler.pkgs=org.apache.catalina.webresources"

rem 如果 LOGGING_CONFIG 没有配置的话
if not "%LOGGING_CONFIG%" == "" goto noJuliConfig

rem 设置 LOGGING_CONFIG = -Dnop
set LOGGING_CONFIG=-Dnop

rem 通常情况下是存在的
if not exist "%CATALINA_BASE%\conf\logging.properties" goto noJuliConfig

rem 设置 LOGGING_CONFIG = -Djava.util.logging.config.file="%CATALINA_BASE%\conf\logging.properties"
set LOGGING_CONFIG=-Djava.util.logging.config.file="%CATALINA_BASE%\conf\logging.properties"
:noJuliConfig
rem 给 JAVA_OPTS 追加 -Djava.util.logging.config.file="%CATALINA_BASE%\conf\logging.properties"
set "JAVA_OPTS=%JAVA_OPTS% %LOGGING_CONFIG%"

if not "%LOGGING_MANAGER%" == "" goto noJuliManager
rem 设置 LOGGING_MANAGER = -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager
set LOGGING_MANAGER=-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager
:noJuliManager
rem 给 JAVA_OPTS 追加 -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager
set "JAVA_OPTS=%JAVA_OPTS% %LOGGING_MANAGER%"

rem ------------------ 设置 JAVA_OPTS 参数 ---------------------------- 结束

rem ----- Execute The Requested Command ---------------------------------------

echo Using CATALINA_BASE:   "%CATALINA_BASE%"
echo Using CATALINA_HOME:   "%CATALINA_HOME%"
echo Using CATALINA_TMPDIR: "%CATALINA_TMPDIR%"

if ""%1"" == ""debug"" goto use_jdk

echo Using JRE_HOME:        "%JRE_HOME%"
goto java_dir_displayed

:use_jdk
echo Using JAVA_HOME:       "%JAVA_HOME%"

:java_dir_displayed
echo Using CLASSPATH:       "%CLASSPATH%"

rem ------------------------ 设置 谁来执行 -------------------------------------
rem 这个 _RUNJAVA 是我们在 setclasspath.bat 中设置的 %JRE_HOME%\bin\java.exe
set _EXECJAVA=%_RUNJAVA%

rem ------------------------ 设置 Tomcat 启动的主类: BootStrap ------------------
set MAINCLASS=org.apache.catalina.startup.Bootstrap

rem 设置启动方式为 start
set ACTION=start

rem 设置安全策略配置文件
set SECURITY_POLICY_FILE=

rem 设置 debug 参数
set DEBUG_OPTS=

rem 设置 JPDA
set JPDA=

if not ""%1"" == ""jpda"" goto noJpda
set JPDA=jpda

if not "%JPDA_TRANSPORT%" == "" goto gotJpdaTransport
set JPDA_TRANSPORT=dt_socket

:gotJpdaTransport
if not "%JPDA_ADDRESS%" == "" goto gotJpdaAddress
set JPDA_ADDRESS=localhost:8000

:gotJpdaAddress
if not "%JPDA_SUSPEND%" == "" goto gotJpdaSuspend
set JPDA_SUSPEND=n

:gotJpdaSuspend
if not "%JPDA_OPTS%" == "" goto gotJpdaOpts
set JPDA_OPTS=-agentlib:jdwp=transport=%JPDA_TRANSPORT%,address=%JPDA_ADDRESS%,server=y,suspend=%JPDA_SUSPEND%

:gotJpdaOpts
shift
:noJpda

rem 调用各个标签执行动作
if ""%1"" == ""debug"" goto doDebug
if ""%1"" == ""run"" goto doRun
if ""%1"" == ""start"" goto doStart
if ""%1"" == ""stop"" goto doStop
if ""%1"" == ""configtest"" goto doConfigTest
if ""%1"" == ""version"" goto doVersion

rem 输出帮助文档
echo Usage:  catalina ( commands ... )
echo commands:
echo   debug             Start Catalina in a debugger
echo   debug -security   Debug Catalina with a security manager
echo   jpda start        Start Catalina under JPDA debugger
echo   run               Start Catalina in the current window
echo   run -security     Start in the current window with security manager
echo   start             Start Catalina in a separate window
echo   start -security   Start in a separate window with security manager
echo   stop              Stop Catalina
echo   configtest        Run a basic syntax check on server.xml
echo   version           What version of tomcat are you running?
goto end

:doDebug
shift
set _EXECJAVA=%_RUNJDB%
set DEBUG_OPTS=-sourcepath "%CATALINA_HOME%\..\..\java"
if not ""%1"" == ""-security"" goto execCmd
shift
echo Using Security Manager
set "SECURITY_POLICY_FILE=%CATALINA_BASE%\conf\catalina.policy"
goto execCmd

:doRun
shift
if not ""%1"" == ""-security"" goto execCmd
shift
echo Using Security Manager
set "SECURITY_POLICY_FILE=%CATALINA_BASE%\conf\catalina.policy"
goto execCmd

rem ----------------- 执行启动 ---------------------------------
:doStart
shift
rem 设置 命令提示符的 Title
if "%TITLE%" == ""
set TITLE=Tomcat

rem 设置 _EXECJAVA = start Tomcat %JRE_HOME%\bin\java.exe
set _EXECJAVA=start "%TITLE%" %_RUNJAVA%

rem 如果没有添加 -security 参数的话, 直接执行启动
if not ""%1"" == ""-security"" goto execCmd
shift
echo Using Security Manager
rem 这个安全策略文件只有在 -security 的时候才会被使用
set "SECURITY_POLICY_FILE=%CATALINA_BASE%\conf\catalina.policy"
goto execCmd

:doStop
shift
set ACTION=stop
set CATALINA_OPTS=
goto execCmd

:doConfigTest
shift
set ACTION=configtest
set CATALINA_OPTS=
goto execCmd

:doVersion
%_EXECJAVA% -classpath "%CATALINA_HOME%\lib\catalina.jar" org.apache.catalina.util.ServerInfo
goto end


:execCmd
rem Get remaining unshifted command line arguments and save them in the
rem 如果没有其它的启动参数化, 就直接去启动
set CMD_LINE_ARGS=
:setArgs
if ""%1""=="""" goto doneSetArgs
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
shift
goto setArgs
:doneSetArgs

rem Execute Java with the applicable properties
rem JPDA 一般不会使用到, 想了解的话可以去查查相关资料, 了解一下
if not "%JPDA%" == "" goto doJpda

rem 这个安全策略文件也很少使用
if not "%SECURITY_POLICY_FILE%" == "" goto doSecurity

rem 通常请款下会执行这里
%_EXECJAVA% %JAVA_OPTS% %CATALINA_OPTS% %DEBUG_OPTS% -Djava.endorsed.dirs="%JAVA_ENDORSED_DIRS%" -classpath "%CLASSPATH%" -Dcatalina.base="%CATALINA_BASE%" -Dcatalina.home="%CATALINA_HOME%" -Djava.io.tmpdir="%CATALINA_TMPDIR%" %MAINCLASS% %CMD_LINE_ARGS% %ACTION%
goto end

:doSecurity
%_EXECJAVA% %JAVA_OPTS% %CATALINA_OPTS% %DEBUG_OPTS% -Djava.endorsed.dirs="%JAVA_ENDORSED_DIRS%" -classpath "%CLASSPATH%" -Djava.security.manager -Djava.security.policy=="%SECURITY_POLICY_FILE%" -Dcatalina.base="%CATALINA_BASE%" -Dcatalina.home="%CATALINA_HOME%" -Djava.io.tmpdir="%CATALINA_TMPDIR%" %MAINCLASS% %CMD_LINE_ARGS% %ACTION%
goto end

:doJpda
if not "%SECURITY_POLICY_FILE%" == "" goto doSecurityJpda
%_EXECJAVA% %JAVA_OPTS% %JPDA_OPTS% %CATALINA_OPTS% %DEBUG_OPTS% -Djava.endorsed.dirs="%JAVA_ENDORSED_DIRS%" -classpath "%CLASSPATH%" -Dcatalina.base="%CATALINA_BASE%" -Dcatalina.home="%CATALINA_HOME%" -Djava.io.tmpdir="%CATALINA_TMPDIR%" %MAINCLASS% %CMD_LINE_ARGS% %ACTION%
goto end

:doSecurityJpda
%_EXECJAVA% %JAVA_OPTS% %JPDA_OPTS% %CATALINA_OPTS% %DEBUG_OPTS% -Djava.endorsed.dirs="%JAVA_ENDORSED_DIRS%" -classpath "%CLASSPATH%" -Djava.security.manager -Djava.security.policy=="%SECURITY_POLICY_FILE%" -Dcatalina.base="%CATALINA_BASE%" -Dcatalina.home="%CATALINA_HOME%" -Djava.io.tmpdir="%CATALINA_TMPDIR%" %MAINCLASS% %CMD_LINE_ARGS% %ACTION%
goto end

:end
