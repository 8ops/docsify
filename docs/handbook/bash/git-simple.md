# git

> 贡献代码

```bash
git remote -v
git remote add upstream https:/xxx #添加源关联到本地
git fetch upstream #更新源至本地 
git merge upstream/master #合并源代码
git push origin master #更新到fork源
```

> 废弃分支

```bash
git remote prune origin
```

## case by case

在mac、linux及windows切换编程时，出现

```bash
$ git diff xx.go
warning: LF will be replaced by CRLF in approval/types.go.
The file will have its original line endings in your working directory.
```

解决

```bash
$ git config --global core.autocrlf input
```

当私有证书验证失败

```bash
$ git config --global sslVerify false
```

## 简易使用

```
删除远程分支
git push origin --delete serverfix
git push origin :serverfix
```

Create a new repository on the command line 

```
touch README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin git@github.com:xtso520ok/hadoop-use.git
git push -u origin master
```

Push an existing repository from the command line 

```
git remote add origin git@github.com:xtso520ok/hadoop-use.git
git push -u origin master
```

by ssh-keygen

```bash
Global setup:
Set up git
git config --global user.name "user_name"
git config --global user.email ×××@×××.com
Add your public key

Next steps:
mkdir project_name
cd project_name
git init
touch README
git add README
git commit -m 'first commit'
git remote add origin git@github.com:user_name/project_name.git
git push -u origin master

Existing Git Repo?
cd existing_git_repo
git remote add origin git@github.com:user_name/project_name.git
git push -u origin master

Importing a Subversion Repo?
Click here
When you're done:
Continue 
[ADD/MODIFY/DELETE] by https
git status -s
git commit -m "Add README document"
git config --global user.name "xtso520ok" 
git config --global user.email xtso520ok@gmail.com 
git status -s 
git push origin master 
```

set pull rebase

```bash
git config --global pull.rebase true
git config --glbal http.sslverify false
```



## 常用操作

```bash
github的提交方式
     （1）git add .--------------------存储到本地
         git commit -m 'message'-------存储时的标记（修改了哪些地方，方便下次查询）
         git pull------------------------下载服务器代码
         git push------------------------上传代码至服务器
  svn服务器的提交方式
   （1）git add .  ------------------存储到本地
        git commit -m 'message'--------存储时的标记（修改了哪些地方，方便下次查询）
        git svn rebase------------------下载服务器代码
        git svn dcommit-----------------上传代码至服务器
   其他相关的git命令
（1）git branch-------------------查看当前属于哪个分支
    1、只有冲突存在时才会修改分支——改为冲突再git add .
    2、git rebase –-continue-------------------自动合并
    3、git checkout –b svn 新建分支名----------新建分支存储现有文件
    4、git branch-------------------------------查看在哪个分支下
    5、git checkout master----------------------将其放到master分支下
    6、git merge-------------------------------整合分支 

    7、git branch -d 分支名----------------------删除分支
（2）git checkout + 上传的commit编号-----------将本地代码恢复到此状态
（3）git log------------------------------------查看本地git上传日志
（4）git log -p app/controllers/grids_controller.rb----查看某个文件的修改历史
（5）git checkout d0eb6ef3afe8a377943d3cf6f1e9c320c18f6f32
     app/controllers/charts_controller.rb-----------返回到这个版本的文件（重现错误） 

（6）git diff ＋ commit编号--------------------------查询不同代码 

```

