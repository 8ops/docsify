
1, 查看前系统连接

ss -ant | awk '{S[$1]++}END{for(s in S)printf("%15s ~ %8d\n",s,S[s])}'
比
netstat -ant | awk '{if(NF==6)S[$NF]++}END{for(s in S)printf("%15s ~ %8d\n",s,S[s])}'
性能高

2, sysctl优化参数







