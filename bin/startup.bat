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
rem Start script for the CATALINA Server
rem 该基本主要做了一下几件事:
rem 1. 设置 CATALINA_HOME 的值
rem 2. 找到 catalina.bat 脚本
rem 3. 得到命令行参数, 并调用 catalina.bat 脚本
rem ---------------------------------------------------------------------------

rem 执行这个命令之后, 增加或者改动的环境变量只限于匹配到 endlocal 命令或者到达文件末尾.
setlocal

rem 假设 CATALINA_HOME 环境变量没有定义

rem 取当前目录的路径值, 赋给 CURRENT_DIR 变量, 一般就是 ./apache-tomcat-x.x.xx/bin
set "CURRENT_DIR=%cd%"

rem 如果 CATALINA_HOME 变量值不是 "" 的话, 调到 gotHome 标签处
if not "%CATALINA_HOME%" == "" goto gotHome

rem 如果 CATALINA_HOME 是 "" 的话, 设置 CATALINA_HOME 变量值为 当前目录的路径值(./apache-tomcat-x.x.xx/bin)
set "CATALINA_HOME=%CURRENT_DIR%"

rem 判断当前路径下的是否有 bin\catalina.bat, 也就是 ./apache-tomcat-x.x.xx/bin/bin/catalina.bat
rem 如果存在的话, 直接调到 okHome 标签处, 显然是不存在的
if exist "%CATALINA_HOME%\bin\catalina.bat" goto okHome

rem 不存在的话, CATALINA_HOME 取上级目录的值, 也就是(./apache-tomcat-x.x.xx/)
cd ..
set "CATALINA_HOME=%cd%"

rem 进入 CURRENT_DIR(./apache-tomcat-x.x.xx/bin)
cd "%CURRENT_DIR%"

:gotHome
rem 通过上面的设置, CATALINA_HOME 的值已经是: ./apache-tomcat-x.x.xx/
rem 所以整理是可以找到 catalina.bat 脚本的, 直接调到 okHome 标签处
if exist "%CATALINA_HOME%\bin\catalina.bat" goto okHome
echo The CATALINA_HOME environment variable is not defined correctly
echo This environment variable is needed to run this program
goto end

:okHome
rem 设置 EXECUTABLE 变量指向为 catalina.bat 脚本
set "EXECUTABLE=%CATALINA_HOME%\bin\catalina.bat"

rem 检查目标可执行文件(catalina.bat)是否存在, 通常情况下是存在的, 直接调到 okExec 标签处
rem 如果不存在的话, 直接退出. 启动 Tomcat 结束
if exist "%EXECUTABLE%" goto okExec
echo Cannot find "%EXECUTABLE%"
echo This file is needed to run this program
goto end

:okExec
rem 获取剩余的 unshifted 命令行参数, 并保存它们在 CMD_LINE_ARGS
set CMD_LINE_ARGS=
:setArgs
rem 如果第一个命令行参数是空的话, 跳到 doneSetArgs 标签处
if ""%1""=="""" goto doneSetArgs
rem 第一个参数不是空的话, 拼接到 CMD_LINE_ARGS 变量
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
rem 这个命令可以自行百度
shift
goto setArgs

:doneSetArgs
rem 上面设置了 EXECUTABLE 变量的值是指向了 catalina.bat 脚本, 这个利用 call 命令执行调用, 并把参数传进去
rem 接下来, 咱们看 catalina.bat 脚本的内容
rem 完整的命令: ./apache-tomcat-x.x.xx/bin/catalina.bat start
call "%EXECUTABLE%" start %CMD_LINE_ARGS%
:end