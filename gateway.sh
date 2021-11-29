#!/bin/bash
#天翼网关用户名
username='useradmin'
#天翼网关密码
password='xxxxxxxxx'
#天翼网关地址
base_url='http://192.168.1.1/cgi-bin/luci'

export token
export cookie

check_predefine(){
  index=0
  operate=$1
  for predefine in "$@"
  do
    if [ $index -eq 0 ]
    then
      let index+=1
      continue
    fi
    if [ $operate = $predefine ]
    then
      return 1
    fi
  done
  return 0  
}

login(){
  data=`curl -Lsc - $base_url --data-raw "username=$username&psd=$password"`
  token=`echo $data | grep -E "token\: '\w+" -o | cut -d "'" -f2 | uniq`
  cookie=`echo $data | grep -E 'sysauth \w*' -o | cut -d ' ' -f2`
}

logout(){
  curl -sb "sysauth=$cookie" '$base_url/admin/logout' --data-raw "token=$token"
}

devinfo(){
  if [ $# -eq 1 ]
  then
    value=`curl -sb "sysauth=$cookie" "$base_url/admin/allInfo"`
  else
    value=`curl -sb "sysauth=$cookie" "$base_url/admin/device/devInfo?type=$2"`
  fi
  echo $value | jq '.'
}

gwinfo(){
  value=`curl -sb "sysauth=$cookie" "$base_url/admin/settings/gwinfo?get=part"`
  echo $value | jq '.'
}

wanip(){
  value=`curl -sb "sysauth=$cookie" "$base_url/admin/settings/gwinfo?get=part"`
  if [[ $# -eq 1 || $2 = '4' ]]
  then
    echo $value | sed 's/.*WANIP\":\"\([0-9.]*\).*/\1/g'
    return 0
  fi
  case $2 in
  '-4')
    echo $value | sed 's/.*WANIP\":\"\([0-9.]*\).*/\1/g'
    ;;
  '-6')
    echo $value | sed 's/.*WANIPv6\":\"\([0-9a-zA-Z:]*\).*/\1/g'
    ;;
  *)
    echo "invalid type $2, -4 -6 are supported"
  esac
}

lsport(){
  value=`curl -sb "sysauth=$cookie" "$base_url/admin/settings/pmDisplay"`
  echo $value | jq '.'
}

addport(){
  if [ $# -ne 6 ]
  then
    echo "addport must have five params, ex: addport name lan_ip type out_port in_port"
    return
  fi
  protocols=('TCP' 'UDP' 'BOTH')
  check_predefine $4 ${protocols[*]}
  if [ $? == 0 ]
  then
    echo "$4 should be one of [${protocols[*]}]"
    return
  fi
  curl -sb "sysauth=$cookie" "$base_url/admin/settings/pmSetSingle" \
    --data-raw "token=$token&op=add&srvname=$2&client=$3&protocol=$4&exPort=$5&inPort=$6"
}

opport(){
  operates=('disable' 'enable' 'del')
  check_predefine $3 ${operates[*]}
  if [ $? -eq 0 ]
  then
    echo "$3 should be one of [${operates[*]}]"
    return
  fi
  curl -sb "sysauth=$cookie" "$base_url/admin/settings/pmSetSingle" \
    --data-raw "token=$token&op=$3&srvname=$2"
}

reboot(){
  curl -sb "sysauth=$cookie" "$base_url/admin/reboot" --data-raw "token=$token"
}

cmds=('gwinfo' 'wanip' 'devinfo' 'lsport' 'addport' 'opport' 'reboot')
if [ $# -eq 0 ]
then
  echo "plase input one of [${cmds[*]}]"
  exit 1
fi
for cmd in ${cmds[*]}
do
  if [ $cmd = $1 ]
  then
    login
    $1 $@
    logout
    exit 0
  fi
done
echo "only [${cmds[*]}] are supported"
