#!bin/bash
function logo(){
	
	echo -e "
\n    ██╗██████╗ ███████╗ ██████╗ █████╗ ███╗   ██╗███╗   ██╗███████╗██████╗ 
    ██║██╔══██╗██╔════╝██╔════╝██╔══██╗████╗  ██║████╗  ██║██╔════╝██╔══██╗
    ██║██████╔╝███████╗██║     ███████║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
    ██║██╔═══╝ ╚════██║██║     ██╔══██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
    ██║██║     ███████║╚██████╗██║  ██║██║ ╚████║██║ ╚████║███████╗██║  ██║
    ╚═╝╚═╝     ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
	"
}
function Using(){
    echo -e "
    usage : ipscan [ -on | -off ] [ -a [n.n.n.n] | -m [n.n.n] [start_number] [end_number] ]\n
     You can replace n with x , and the range of x is 1~254.\n
     	Option :\n
     		-on     Computer showing online.
     		-off    Computer showing offline.
     		-a      Only one set of data.
     		-m      Multiple data.
     		-g      Get network information.\n
     	example : \n
     		ipscan -a 192.168.1.1
     		ipscan -on -a 192.168.1.x
     		ipscan -off -m 192.168.1 1 5
     		ipscan -on -m 192.168.1 1 5 -off -m 192.168.1 6 10"
    exit
}

function Scan(){
    [ $4 == 0 ] && status=online || status=offline
    trap "exit" INT
    for i in $(seq $2 $3);do
        ping -c 1 -w 1 $1.$i >/dev/null
        [ "$?" == "$4" ] && printf "%s : %s\n" $1.$i $status
    done
    return 0
}

function GetData(){
    GateWay=`route -n | grep 'UG[ \t]' | awk '{print $2}'`
    MyLANIP=`hostname -I`
    MyWANIP=`dig +short myip.opendns.com @resolver1.opendns.com`
    printf "GateWay IP:%s\nWAN IP:%s\nLAN IP:%s\n" $GateWay $MyWANIP $MyLANIP
}

function parmLoop(){
    flag=0
    until [ -z "$1" ];do
        if [ "$1" == "-g" ];then
            shift 1
            GetData
        elif [ "$1" == "-on" ];then
            flag=0
            shift 1
            continue
        elif [ "$1" == "-off" ];then
            flag=1
            shift 1
            continue
        elif [ "$1" == "-a" ];then
            ary_count=0
            for i in ${2//\./\ };do
                ip_ary[$count]=$i
                let count=$[count+1]
            done
            [ "${ip_ary[3]}" == "x" ] && Scan ${ip_ary[0]}.${ip_ary[1]}.${ip_ary[2]} 1 254 $flag || Scan ${ip_ary[0]}.${ip_ary[1]}.${ip_ary[2]} ${ip_ary[3]} ${ip_ary[3]} $flag
            shift 1
            shift 1
            continue
        elif [ "$1" == "-m" ];then
            Scan $2 $3 $4 $flag
            for i in {1..4};do
                shift 1
            done
            continue
        fi
    done
}

logo
[ "$1" == "" ] && Using || parmLoop $*
exit 0
