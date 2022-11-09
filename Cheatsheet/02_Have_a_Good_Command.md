# Have a Good Command

## Overview

## Recording and playing back terminalsessions

script和scriptreplay命令在绝大多数GNU/Linux发行版上都可以找到

可以通过录制终端会话来制作命令行技巧视频教程，也可以与他人分享会话记录文件，研究如何使用命令行完成某项任务

example:

```bash
$ script -t 2> timing.log -a output.session

# 演示tclsh
$ tclsh
$ puts [expr 2 + 2]
4
% exit
$ exit
```

`-t`选项将时间戳写入timing.log文件，`-a`选项将会话记录写入output.session文件

利用文件timing.log和output.session，可以按照下面的方法回放命令执行过程

```bash
$ scriptreplay timing.log output.session
# will playing
```

## Finding files and file listing

find命令的工作方式如下：沿着文件层次结构向下遍历，匹配符合条件的文件，执行相应
的操作。默认的操作是打印出文件和目录，这也可以使用-print选项来指定。

example:
```bash
$ find . -print
.history
...
```
print选项使用\n（换行符）分隔输出的每个文件或目录名

而-print0选项则使用空字符'\0'来分隔

-print0的主要用法是将包含换行符或空白字符的文件名传给xargs命令

example:
```bash
$> echo "test" > "file name"
$> find . -type f -print | xargs ls -l
ls: cannot access /file: No such file or directory
ls: cannot access name: No such file or directory
$> find . -type f -print0 | xargs -0 ls -l
-rw-r--r-- 1 user group 5 Aug 24 15:00 ./file name
```

### Search based on name or regular expression match

find命令的-name选项可以根据文件名进行搜索
这个模式可以是通配符，也可以是正则表达式

example:
```bash
$ find . -name "*.txt"
./file.txt
./file2.txt
```

注意*.txt两边的单引号。shell会扩展没有引号或是出现在双引号（"）中
的通配符。单引号能够阻止shell扩展*.txt，使得该字符串能够原封不动地传给
find命令

```bash
$ find /home/slynux -name '*.txt' -print
```

#### 忽略字母大小写

find命令有一个选项-iname（忽略字母大小写），该选项的作用和-name类似，只不过在匹

配文件名时忽略字母大小写

```bash
$ ls
example.txt EXAMPLE.txt file.txt
$ find . -iname "example*" -print
./example.txt
./EXAMPLE.txt
```

#### find 逻辑操作符
find命令支持逻辑操作符。-a和-and选项可以执行逻辑与（AND）操作，
-o和-or选项可以执行逻辑或（OR）操作。

example:
```bash
$ ls
new.txt some.jpg text.pdf stuff.png
$ find . \( -name "*.txt" -o -name "*.pdf" \) -print
./text.txt
./next.txt
```
\（以及\）用于将-name '*.txt' -o -name '*.pdf'视为一个整体。

下面的命令演示了如何使用-and操作符选择名字以s开头且其中包含e的文件：
```bash
$ find . \( -name '*e*' -and -name 's*' \) -print
```

#### 限制所匹配文件的路径以及名称

-path选项可以限制所匹配文件的路径及名称。例如，$ find /home/users -path
'*/slynux/*' -name '*.txt' –print能够匹配文件/home/users/slynux/readme.txt，但无法匹
配/home/users/slynux.txt。

III :-regex选项和-path类似，只不过前者是基于正则表达式来匹配文件路径的。

下面的命令可以匹配.py或.sh文件：

```bash
$ ls
new.PY next.jpg test.py script.sh
$ find . -regex '.*\.\(py\|sh\)'
./test.py
script.sh
```

-iregex 选项可以让正则表达式在匹配时忽略大小写。

example:
```bash
$ find . -iregex '.*\.\(py\|sh\)$'
./test.py
./new.PY
./script.sh
```

### Negating arguments

find也可以用!排除匹配到的模式：

```bash
$ find . ! -name '*.txt' -print
.
./next.txt
./test.txt
./new.txt
```

### Searching based on the directory depth

find命令在查找时会遍历完所有的子目录。默认情况下，find命令不会跟随符号链接。-L选项可以强制其改变这种行为。但如果碰上了指向自身的链接，find命令就会陷入死循环中。

-maxdepth和–mindepth选项可以限制find命令遍历的目录深度。这可以避免find命令没完没了地查找。

/proc文件系统中包含了系统与当前执行任务的信息。特定任务的目录层次相当深，其中还有一些绕回到自身（loop back on themselves）的符号链接。
系统中运行的每个进程在proc中都有对应的子目录，其名称就是该进程的进程ID。这个目录下有一个叫作cwd的链接，指向进程的当前工作目录。

example:
```bash
$ find -L /proc -maxdepth 1 -name 'bundlemaker.def' 2>/dev/null
```

- -L选项告诉find命令跟随符号链接
- 从/proc目录开始查找
- -maxdepth 1将搜索范围仅限制在当前目录
- -name 'bundlemaker.def'指定待查找的文件
- 2>/dev/null将有关循环链接的错误信息发送到空设备中

Tips:
-maxdepth和-mindepth应该在find命令中及早出现。如果作为靠后的选项
，有可能会影响到find的效率，因为它不得不进行一些不必要的检查。例如，
如果-maxdepth出现在-type之后，find首先会找出-type所指定的文件，然
后再在匹配的文件中过滤掉不符合指定深度的那些文件。但是如果反过来，在
-type之前指定目录深度，那么find就能够在找到所有符合指定深度的文件后,
再检查这些文件的类型，这才是最有效的搜索之道。


### Searching based on file type


















## Renaming and moving files in bulk

use tool rename

下面的脚本利用find查找PNG和JPEG文件，然后使用##操作符和mv将查找到的文件重命名

```bash
#!/bin/bash
# rename.sh
# Renames all .jpg and .png files in the current directory

count=1;
for img in `find . -iname '*.png` -o -iname '*.jpg' -type f -maxdepth 1`
do
    new=image-$count.${img##*.}
    echo "Renaming $img to $new"
    mv "$img" "$new"
    let count++
done
```

output below:
```bash
$ ./rename.sh
Renaming ./hack.jpg to image-2.jpg
Renaming ./new.jpg to image-3.jpg
Renaming ./next.jpg to image-1.jpg
```

该脚本重命名了当前目录下所有的.jpg和.png文件，新文件名采用形如image-1.jpg、image-2.jpg
image-3.png、image-4.png的格式

使用了for循环迭代所有扩展名为.jpg或.png的文件。我们使用find
命令展开搜索，选项-o用于指定多个-iname选项，后者用于进行大小写无关的匹配。选项
-maxdepth 1仅搜索当前目录，不涉及其中的子目录。

为了跟踪图像编号，我们将变量count初始化为1。接下来用mv命令重命名文件。新的文件
名通过${img##*.}来构造，它能够从当前处理的文件名中解析出扩展名（请参看2.12节中对于
${img##*.}的解释）。let count++用来在每次循环中递增文件编号。

### More

- 将*.JPG更名为*.jpg：
```bash
$ rename *.JPG *.jpg
```

- 将文件名中的空格替换成字符"_"：
```bash
$ rename 's/ /_/g' *
```

's/ /_/g'用于替换文件名，而*是用于匹配目标文件的通配符，它也可以写成*.txt
或其他通配符模式。

- 转换文件名的大小写：
```bash
$ rename 'y/A-Z/a-z/' *
$ reanme 'y/a-z/A-Z/' *
```

- 将所有的.mp3文件移入给定的目录：

```bash
$ find path -type f -name "*.mp3" -exec mv {} target_dir \;
```

- 以递归的方式将所有文件名中的空格替换为字符"_"：

```bash
$ find path -type f -exec rename 's/ /_/g' {} \;
```
