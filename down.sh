#!/bin/bash
cd "$(dirname "$0")"

LINK="$1"
if ! grep -P '^https://www.everyonepiano.cn/(Number|Stave)-\d+.html$' <<< "$LINK" &> /dev/null
then
  echo 输入链接错误,需要在线乐谱架地址
  exit 1
fi

TITLE=$(curl -ks $LINK | grep -Po '(?<=<title>).+(?=</title>)' | sed -r 's/(预览-EOP在线乐谱架)| //g')
IMGS=($(curl -ks $LINK | grep DownMusicPNG | grep -Po '(?<=<img src=")[^"]+'))
echo "$TITLE" 共${#IMGS[*]}页

SAVEDIR="$(date +%Y%m%d-%H%M%S)-$TITLE"
mkdir "$SAVEDIR"

for page in ${IMGS[@]}
do
	CTR=$[CTR+1]
	echo 下载第${CTR}页
	URL=https://www.everyonepiano.cn/$page
	curl -kso "$SAVEDIR/$(printf %05d $CTR).png" $URL
done

echo 合并pdf
if which convert &> /dev/null
then
	convert $SAVEDIR/*.png $SAVEDIR/${TITLE}.pdf
else
	echo 合并失败,未找到convert命令,请安装imagemagick
fi

