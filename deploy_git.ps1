Get-ChildItem ..\hexo_tech_blog\source\_posts *.md* -Recurse | del
$foldersItem = (Get-ChildItem source\ *.md -Recurse).FullName 
$destinationPath = "..\hexo_tech_blog\source\_posts"
foreach($item in $foldersItem)
{
    Copy-Item $item -Destination $destinationPath
}
cd ..\hexo_tech_blog
PowerShell -ExecutionPolicy RemoteSigned hexo clean
PowerShell -ExecutionPolicy RemoteSigned hexo deploy -g