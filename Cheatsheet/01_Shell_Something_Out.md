# Shell Something Out

## Overview

## Displaying output in a terminal

使用echo和printf的命令选项时，要确保选项出现在命令中的所有字符串之前，否则Bash会将其视为另外一个字符串。

要打印彩色文本，可输入如下命令：
```bash
echo -e "\e[1;31m This is red text \e[0m"
```

其中包括：重置=0，黑色=30，红色=31，绿色=32，黄色=33，蓝色=34，洋红=35，青色=36，白色=37。

## Using variables and environment variables

#### get PID
我们可以使用pgrep命令获得gedit的进程ID：
```bash
pgrep gedit 12501
```

#### check out the environment variables
要想生成一份易读的报表，可以将cat命令的输出通过管道传给tr，将其中的\0替换成\n
```bash
cat /proc/12501/environ  | tr '\0' '\n'
```

#### add environment path
```bash
export PATH="$PATH:/home/username/bin"
```

#### Finding the length of a string
```bash
var=123456
length=${#var}
echo length
```

#### Identifying the current shell

```bash
echo $SHELL
# or
echo $0
```

#### Checking for super user

```bash
if [ "$UID" -ne 0 ]; then
  echo Non root user. Please run as root.
else
  echo Root user
fi
```

```bash
if test $UID -ne 0; then
  echo Non root user. Please run as root.
else
  echo Root user
fi
```

## Function to prepend to environmentvariables

我们可以在.bashrc文件中定义如下函数，简化路径添加操作：
```bash
prepend() { [ -d "$2" ] && eval $1=\"$2\$\{$1:+':'\$$1\}\" && export $1 ; }
```

usage:
```bash
prepend PATH /opt/myapp/bin
prepend LD_LIBRARY_PATH /opt/myapp/lib
```

## Playing with file descriptors and redirection

#### get return value of a command
```bash
echo $?
```

#### stderr and stdout redirection
可以将stderr和stdout分别重定向到不同的文件中
```bash
cmd 2>stderr.txt 1>stdout.txt
```
将stderr转换成stdout，使得stderr和stdout都被重定向到同一个文件中
```bash
cmd 2>&1 alloutput.txt
# or
cmd &> output.txt
```

stdout作为单数据流（single stream），可以被重定向到文件或是通过管道传入其他程序，但是无法两者兼得。
有一种方法既可以将数据重定向到文件，还可以提供一份重定向数据的副本作为管道中后续命令的stdin。
tee命令从stdin中读取，然后将输入数据重定向到stdout以及一个或多个文件中。
```bash
command | tee FILE1 FILE2 | otherCommand
```

在下面的代码中，tee命令接收到来自stdin的数据。它将stdout的一份副本写入文件out.txt，同时将另一份副本作为后续命令的stdin。命令cat -n为从stdin中接收到的每一行数据前加上行号并将其写入stdout：
```bash
cat a* | tee out.txt | cat -n
```
out:
```bash
cat: a1: Permission denied
    1 A2
    2 A3 
```
注意，cat: a1: Permission denied并没有在文件内容中出现，
因为这些信息被发送到了stderr，而tee只能从stdin中读取

追加：
```bash
cat a* | tee -a out.txt | cat –n
```

#### Redirection from a file to a command

借助小于号（<），我们可以像使用stdin那样从文件中读取数据
```bash
cmd < file
```

#### Redirecting from a text block enclosed within a script

可以将脚本中的文本重定向到文件。要想将一条警告信息添加到自动生成的文件顶部
```bash
#!/bin/bash
cat<<EOF>log.txt
This is a generated file. Do not edit. Changes will be overwritten.
EOF
```

#### Custom file descriptors

创建一个用于读取文件的文件描述符：
```bash
$ exec 3<input.txt    #使用文件描述符3打开并读取文件
```
usage:
```bash
echo this is a test line > input.txt 
exec 3<input.txt
```

创建一个用于写入（截断模式）的文件描述符：
```bash
exec 4>output.txt   #打开文件进行写入
```
usage:
```bash
$ exec 4>output.txt 
$ echo newline >&4 
$ cat output.txt
newline
```
创建一个用于写入（追加模式）的文件描述符：
```bash
exec 5>>input.txt   #打开文件进行追加
```
usage:
```bash
$ exec 5>>input.txt
$ echo appended line >&5
$ cat input.txt
newline
append line
```

## alias

#### sudo alias

如果身份为特权用户，别名也会造成安全问题。为了避免对系统造成危害，你应该将命令转义

1. 对别名进行转义

创建一个和原生命令同名的别名很容易，你不应该以特权用户的身份运行别名化的命令。
我们可以转义要使用的命令，忽略当前定义的别名：

```bash
$ \command
```
字符\可以转义命令，从而执行原本的命令。
在不可信环境下执行特权命令时，在命令前加上\来忽略可能存在的别名总是一种良好的安全实践。
这是因为攻击者可能已经将一些别有用心的命令利用别名伪装成了特权命令，借此来盗取用户输入的重要信息。

#### show all of the aliases

```bash
alias
```

## Debugging the script

我们可以利用Bash内建的调试工具或者按照易于调试的方式编写脚本，方法如下所示。

(1) 使用选项-x，启用shell脚本的跟踪调试功能：

```bash
bash -x script.sh
```

(2) 使用set -x和set +x对脚本进行部分调试。例如：

```bash
#!/bin/bash
for i in {1..6};
do
    set -x
    echo $i
    set +x
done
echo "Script executed"
```

(3) 前面介绍的调试方法是Bash内建的。
它们以固定的格式生成调试信息。
但是在很多情况下，我们需要使用自定义的调试信息。
可以通过定义_DEBUG环境变量来启用或禁止调试及生成特定形式的信息。

```bash
function DEBUG()
{
    [ "$_DEBUG" == "on" ] && $@ || :
}
for i in {1..10}
do
    DEBUG echo $i
done
```

```bash
$ _DEBUG=on ./script.sh
```

我们在每一条需要打印调试信息的语句前加上DEBUG。如果没有把_DEBUG=on传递给脚本，那么调试信息就不会打印出来。在Bash中，命令:告诉shell不要进行任何操作。

调试的输出信息可能会很长。如果使用了-x或set -x，调试输出会被发送到stderr。可以使用下面的命令将其重定向到文件中：

```bash
bash -x script.sh 2> debug.log
```

#### Exporting functions

函数也能像环境变量一样用export导出，如此一来，函数的作用域就可以扩展到子进程中：
```bash
export -f fname
$> function getIP() { /sbin/ifconfig $1 | grep 'inet '; }$> echo "getIP eth0" >test.sh$> sh test.sh  sh: getIP: No such file or directory$> export -f getIP$> sh test.sh  inet addr: 192.168.1.2 Bcast: 192.168.255.255 Mask:255.255.0.0
$> echo "getIP eth0" >test.sh
$> sh test.sh
    sh: getIP: No such file or directory
$> export -f getIP
$> sh test.sh
    inet addr: 192.168.1.2 Bcast: 192.168.255.255 Mask:255.255.0.0
```

## Sending output from one command toanother

#### Spawning a separate process with subshell

子shell本身就是独立的进程。可以使用()操作符来定义一个子shell

```bash
$> pwd
/
$>(cd /bin; ls)
awk bash cat...
$>pwd
```

当命令在子shell中执行时，不会对当前shell造成任何影响；所有的改变仅限于该子shell内。
例如，当用cd命令改变子shell的当前目录时，这种变化不会反映到主shell环境中。

## Running a command until it succeeds

```bash
repeat() {
    while true; do
        $@ && return
        sleep 1
    done
}
```

##### A faster approach

在大多数现代系统中，true是作为/bin中的一个二进制文件来实现的。这就意味着每执行一
次之前提到的while循环，shell就不得不生成一个进程。为了避免这种情况，可以使用shell的内
建命令:，该命令的退出状态总是为0：

## Comparisons and tests

A tips

- [ condition ] && action;    # 如果condition为真，则执行action
- [ condition ] || action;    # 如果condition为假，则执行action

```bash
[ $var -eq 0]
```

- gt：大于
- lt：小于
- ge：大于等于
- le：小于等于

-a是逻辑与操作符，-o是逻辑或操作符。可以按照下面的方法结合多个条件进行测试：

- [ $var1 -ne 0 -a $var2 -gt 2 ]    #使用逻辑与-a
- [ $var1 -ne 0 -o $var2 -gt 2 ]    #逻辑或-o

文件系统相关测试

- [ -f $file_var ]：如果给定的变量包含正常的文件路径或文件名，则返回真
- [ -x $var ]：如果给定的变量包含的文件可执行，则返回真
- [ -d $var ]：如果给定的变量包含的是目录，则返回真
- [ -e $var ]：如果给定的变量包含的文件存在，则返回真
- [ -c $var ]：如果给定的变量包含的是一个字符设备文件的路径，则返回真
- [ -b $var ]：如果给定的变量包含的是一个块设备文件的路径，则返回真
- [ -w $var ]：如果给定的变量包含的文件可写，则返回真
- [ -r $var ]：如果给定的变量包含的文件可读，则返回真
- [ -L $var ]：如果给定的变量包含的是一个符号链接，则返回真

### String comparisons:

进行字符串比较时，最好用双中括号，因为有时候采用单个中括号会产生错误。

注意，双中括号是Bash的一个扩展特性。如果出于性能考虑，使用ash或dash
来运行脚本，那么将无法使用该特性

## Customizing bash with configuration files

配置文件分为3类：登录时执行的、
启动交互式shell时执行的以及调用shell处理脚本文件时执行的

当用户登录shell时，会执行下列文件
```bash

`/etc/profile, $HOME/.profile, $HOME/.bash_login, $HOME/.bash_profile /``

注意，如果你是通过图形化登录管理器登入的话，是不会执行/etc/profile

$HOME/.profile和$HOME/.bash_profile这3个文件的。这是因为图形化窗口管理器

并不会启动shell。当你打开终端窗口时才会创建shell，但这个shell也不是登录shell

如果.bash_profile或.bash_login文件存在，则不会去读取.profile文件。
