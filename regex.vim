let l = matchlist('ssh://git@github.com:hoge/fuga.git', '\v^.*git\@(.{-})(:|\/)(.{-})(.git|)$')
echo l
