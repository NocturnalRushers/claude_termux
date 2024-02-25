#!/bin/bash

version="Ver2.0.3"
echo "卡在这里了？...说明没开魔法"
latest_version=$(curl -s https://raw.githubusercontent.com/NocturnalRushers/claude_termux/main/VERSION)
#

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 检查是否存在git指令
if command -v git &> /dev/null; then
    echo "git指令存在"
    git --version
else
    echo "git指令不存在，建议回termux下载git"
fi

# 检查是否存在node指令
if command -v node &> /dev/null; then
    echo "node指令存在"
    node --version
else
    echo "node指令不存在，正在尝试重新下载"
    curl -O https://nodejs.org/dist/v20.10.0/node-v20.10.0-linux-arm64.tar.xz
    tar xf node-v20.10.0-linux-arm64.tar.xz
    echo "export PATH=\$PATH:/root/node-v20.10.0-linux-arm64/bin" >>/etc/profile
    source /etc/profile
    if command -v node &> /dev/null; then
        echo "node成功下载"
        node --version                                                
    else
        echo "node下载失败，自己尝试手动下载吧"
        exit 1

  fi
fi

#添加termux上的Ubuntu/root软链接
if [ ! -d "/data/data/com.termux/files/home/root" ]; then
    ln -s /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/root /data/data/com.termux/files/home
fi

echo "root软链接已添加，可直接在mt管理器打开root文件夹修改文件"

if [ ! -d "SillyTavern" ] || [ ! -f "SillyTavern/start.sh" ]; then
    echo "SillyTavern不存在，正在通过git下载..."
	cp -r SillyTavern/public SillyTavern_public_bak
	rm -rf SillyTavern
    git clone https://github.com/SillyTavern/SillyTavern SillyTavern
    echo -e "\033[0;33m本操作仅为破限下载提供方便，所有破限皆为收录，不具有破限所有权\033[0m"
    read -p "回车进行导入破限"
    rm -rf /root/st_promot
    git clone https://github.com/NocturnalRushers/promot.git /root/st_promot
    if  [ ! -d "/root/st_promot" ]; then
        echo -e "\n\033[0;33m 因网络波动预设文件下载失败了，更换网络后再试\n\033[0m"
    else
    cp -r /root/st_promot/. /root/SillyTavern/public/'OpenAI Settings'/
    echo -e "\033[0;33m破限已成功导入，安装完毕后启动酒馆即可看到\033[0m"
    fi
fi

if [ ! -d "clewd" ]; then
	echo "clewd不存在，正在通过git下载..."
	git clone -b test https://github.com/teralomaniac/clewd
	cd clewd
	bash start.sh
        cd /root
elif [ ! -f "clewd/config.js" ]; then
    cd clewd
    bash start.sh
    cd /root
fi

if [ ! -d "SillyTavern" ] || [ ! -f "SillyTavern/start.sh" ]; then
	echo -e "\n\033[0;33m 因网络波动文件下载失败了，更换网络后再试\n\033[0m"
 	rm -rf SillyTavern
	exit 2
fi

if  [ ! -d "clewd" ] || [ ! -f "clewd/config.js" ]; then
	echo -e "\n\033[0;33m 因网络波动文件下载失败了，更换网络后再试\n\033[0m"
  	rm -rf clewd
	exit 3
fi

function clewdSettings { 
    # 3. Clewd设置
    clewd_dir=clewd
    echo -e "\033[0;36m选一个执行\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;33m选项1 查看 config.js 配置文件\n\033[0m\033[0;37m选项2 使用 Vim 编辑 config.js\n\033[0m\033[0;33m选项3 添加 Cookies\n\033[0m\033[0;37m选项4 修改 Clewd 密码\n\033[0m\033[0;33m选项5 修改 Clewd 端口\n\033[0m\033[0;37m选项6 修改 Cookiecounter\n\033[0m\033[0;33m选项7 修改 rProxy\n\033[0m\033[0;37m选项8 修改 PreventImperson状态\n\033[0m\033[0;33m选项0 更新 clewd(test分支)\n\033[0m\033[0;33m--------------------------------------\n\033[0m"
    read -n 1 option
    echo
    case $option in 
        1) 
            # 查看 config.js
            cat $clewd_dir/config.js
            ;;
        2)
            # 使用 Vim 编辑 config.js
            vim $clewd_dir/config.js
            ;;
        3) 
            # 添加 Cookies
            echo "请输入你的cookie文本(回车进行保存，如果全部输入完后按一次ctrl+D即可退出输入):"
            while IFS= read -r line; do
                cookies=$(echo "$line" | grep -E -o '"?sessionKey=[^"]{100,120}AA"?' | tr -d "\"'")
                echo "$cookies"
                if [ -n "$cookies" ]; then
                    echo -e "猜你的cookies是:\n"
                    echo "$cookies"
                    # Format cookies, one per line with quotes
                    cookies=$(echo "$cookies" | tr ' ' '\n' | sed -e 's/^/"/; s/$/"/g')
                    # Join into array
                    cookie_array=$(echo "$cookies" | tr '\n' ',' | sed 's/,$//')
                    # Update config.js
                    sed -i "/\"CookieArray\"/s/\[/\[$cookie_array\,/" ./$clewd_dir/config.js
                    echo "Cookies成功被添加到config.js文件了"
                else
                    echo "没有找到cookieo(╥﹏╥)o，要不检查一下cookie是不是输错了吧？(如果要退出输入请按Ctrl+D)"
                fi
            done
            echo "cookies成功输入了(*^▽^*)"
            ;;
        4) 
            # 修改 Clewd 密码
            read -p "是否修改密码?(y/n)" choice
            if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
                # 读取用户输入的新密码
                read -p "请输入新密码\n（不是你本地部署设密码干哈啊？）:" new_pass

                # 修改密码
                sed -i 's/"ProxyPassword": ".*",/"ProxyPassword": "'$new_pass'",/g' $clewd_dir/config.js

                echo "密码已修改为$new_pass"
            else
                echo "未修改密码"
            fi
            ;; 
        5) 
            # 修改 Clewd 端口
            read -p "是否要修改开放端口?(y/n)" choice
            if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
                # 读取用户输入的端口号
                read -p "请输入开放的端口号:" custom_port

                # 更新配置文件的端口号
                sed -i 's/"Port": [0-9]*/"Port": '$custom_port'/g' $clewd_dir/config.js
                echo "端口已修改为$custom_port"
            else
                echo "未修改端口号"
            fi
            ;;
        6)  
            # 修改 Cookiecounter
            echo "切换Cookie的频率, 默认为3(每3次切换), 改为-1进入测试Cookie模式"
            read -p "是否要修改Cookiecounter?(y/n)" choice
            if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
                # 读取用户输入Cookiecounter
                read -p "请输入需要设置的数值:" cookiecounter

                # 更新配置文件的Cookiecounter
                sed -i 's/"Cookiecounter": .*,/"Cookiecounter": '$cookiecounter',/g' $clewd_dir/config.js
                echo "Cookiecounter已修改为$cookiecounter"
            else
                echo "未修改Cookiecounter"
            fi
            ;;
        7)  
            # 修改 rProxy
            echo -e "\n1. 官网地址claude.ai\n2. 国内镜像地址finechat.ai\n3. 自定义地址\n0. 不修改"
            read -p "输入选择：" choice
            case $choice in 
                1)  
                    sed -i 's/"rProxy": ".*",/"rProxy": "",/g' $clewd_dir/config.js
                    ;; 
                2) 
                    sed -i 's#"rProxy": ".*",#"rProxy": "https://chat.finechat.ai",#g' $clewd_dir/config.js
                    ;; 
                3)
                    # 读取用户输入rProxy
                    read -p "请输入需要设置的数值:" rProxy
                    # 更新配置文件的rProxy
                    sed -i 's#"rProxy": ".*",#"rProxy": "'$rProxy'",#g' $clewd_dir/config.js
                    echo "rProxy已修改为$rProxy"
                    ;; 
                *) 
                    echo "不修改"
                    break ;; 
            esac
            ;;
        8)
            PreventImperson_value=$(grep -oP '"PreventImperson": \K[^,]*' clewd/config.js)
            echo -e "当前PreventImperson值为\033[0;33m $PreventImperson_value \033[0m"
            read -p "是否进行更改[y/n]" PreventImperson_choice
            if [ $PreventImperson_choice == "Y" ] || [ $PreventImperson_choice == "y" ]; then
                if [ $PreventImperson_value == 'false' ];
    then
                    #将false替换为true
                    sed -i 's/"PreventImperson": false,/"PreventImperson": true,/g' $clewd_dir/config.js
                    echo -e "'PreventImperson'已经被修改成\033[0;33m true \033[0m."
                elif [ $PreventImperson_value == 'true' ];
    then
                    #将true替换为false
                    sed -i 's/"PreventImperson": true,/"PreventImperson": false,/g' $clewd_dir/config.js
                    echo -e "'PreventImperson'值已经被修改成\033[0;33m false \033[0m."
                else
                    echo -e "\n未能找到'PreventImperson'."
                fi
            else
                echo "未进行修改"
            fi
            ;;
        0)
			echo -e "选择更新模式(两种模式都会保留重要数据)\n\033[0;33m--------------------------------------\n\033[0m\033[0;33m选项1 使用git pull进行简单更新\n\033[0m\033[0;37m选项2 几乎重新下载进行全面更新\n\033[0m"
            read -n 1 -p "" clewdup_choice
			echo
			cd /root
			case $clewdup_choice in
				1)
					cd /root/clewd
					git checkout -b test origin/test
					git pull
					;;
				2)
					git clone -b test https://github.com/teralomaniac/clewd.git /root/clewd_new
					if [ ! -d "clewd_new" ]; then
						echo -e "\n\033[0;33m 因为网络波动下载失败了，更换网络再试\n\033[0m"
						exit 5
					fi
					cp -r clewd/config.js clewd_new/config.js
					if [ -f "clewd_new/config.js" ]; then
						echo "config.js配置文件已转移，正在删除旧版clewd"
						rm -rf /root/clewd
						mv clewd_new clewd
					fi
					;;
			esac
            ;;
        *)
            echo "什么都没有执行"
            ;;
    esac
}

function sillyTavernSettings {
    # 4. SillyTavern设置
	echo -e "\033[0;36m选一个执行\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;33m选项1 修改酒馆端口\n\033[0m\033[0;37m选项2 导入最新整合预设\n\033[0m\033[0;33m选项3 导入DC总结插件by(Darker than Black)\n\033[0m\033[0;37m选项0 更新酒馆\n\033[0m\033[0;33m--------------------------------------\n\033[0m"
    read -n 1 option
    echo
    case $option in 
        0)
			echo -e "选择更新模式(重要数据会进行转移，但最好自己有备份)\n\033[0;33m--------------------------------------\n\033[0m\033[0;33m选项1 使用git pull进行简单更新\n\033[0m\033[0;37m选项2 几乎重新下载进行全面更新\n\033[0m"
            read -n 1 -p "" stup_choice
			echo
			cd /root
			case $stup_choice in
				1)
					cd /root/SillyTavern
					git pull
					;;
				2)
					if [ -d "SillyTavern_old" ]; then                                   
						NEW_FOLDER_NAME="SillyTavern_$(date +%Y%m%d)"
						mv SillyTavern_old $NEW_FOLDER_NAME
					fi                                                                
					git clone https://github.com/SillyTavern/SillyTavern.git SillyTavern_new

					if [ ! -d "SillyTavern_new" ]; then
						echo -e "\n\033[0;33m 因为网络波动下载失败了，更换网络再试\n\033[0m"
						exit 5
					fi
				
					cp -r SillyTavern/public/characters/. SillyTavern_new/public/characters/
					cp -r SillyTavern/public/chats/. SillyTavern_new/public/chats/       
					cp -r SillyTavern/public/worlds/. SillyTavern_new/public/worlds/
					cp -r SillyTavern/public/groups/. SillyTavern_new/public/groups/
					cp -r SillyTavern/public/group\ chats/. SillyTavern_new/public/group\ chats/
					cp -r SillyTavern/public/OpenAI\ Settings/. SillyTavern_new/public/OpenAI\ Settings/
					cp -r SillyTavern/public/User\ Avatars/. SillyTavern_new/public/User\ Avatars/
					cp -r SillyTavern/public/backgrounds/. SillyTavern_new/public/backgrounds/
					cp -r SillyTavern/public/settings.json SillyTavern_new/public/settings.json
					mv SillyTavern SillyTavern_old                                    
					mv SillyTavern_new SillyTavern

					read -p "是否删除旧版本,请输入Y/N:" para
					case $para in
						[yY])
							read -p "若要删除请再次确认" queren
							case $queren in
								[yY])
									rm -rf SillyTavern_old
									echo "酒馆更新成功了"
									;;
								[nN])
									echo "保留旧版本"
									echo "酒馆更新结束了"
									;;
								*)
									echo "错误的输入"
									read -p "已经默认保留旧版本"
									echo "酒馆更新结束了"
									;;
							esac
							;;
						*)
							echo "保留旧版本"
							;;
					esac
					;;
			esac
            ;;
		1)
			if [ ! -f "SillyTavern/config.yaml" ]; then
				echo -e "当前酒馆版本过低，请更新酒馆版本后重试"
				exit
			fi
            read -p "是否要修改开放端口?(y/n)" choice

            if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
                # 读取用户输入的端口号
                read -p "请输入开放的端口号:" custom_port
                # 更新配置文件的端口号
                sed -i 's/port: [0-9]*/port: '$custom_port'/g' SillyTavern/config.yaml
                echo "端口已修改为$custom_port"
            else
                echo "未修改端口号"
            fi
            ;;
        2)
            #导入破限
            echo -e "\033[0;33m本操作仅为破限下载提供方便，所有破限皆为收录，不具有破限所有权\033[0m"
            read -p "回车进行导入破限"
            rm -rf /root/st_promot
            git clone https://github.com/NocturnalRushers/promot.git /root/st_promot
            if  [ ! -d "/root/st_promot" ]; then
            echo -e "\n\033[0;33m 因网络波动文件下载失败了，更换网络后再试\n\033[0m"
            exit 6
            fi
            cp -r /root/st_promot/. /root/SillyTavern/public/'OpenAI Settings'/
            echo -e "\033[0;33m破限已成功导入，启动酒馆看看\033[0m"
            ;;
        3)
            #DC总结插件by(Darker than Black)
            echo -e "\033[0;33m插件作者为Darker than Black,发布于DC类脑频道\n具体地址为:\n\033[0m"
            echo "https://discord.com/channels/1134557553011998840/1190219779458486292"
            read -p "回车进行导入插件"
            cd /root/SillyTavern/public/QuickReplies
            curl -O https://cdn.discordapp.com/attachments/1190219779458486292/1190219779856932864/f96ce3edc4220761.json?ex=65bcb10c&is=65aa3c0c&hm=15ede2b950edc8038397bed82ef5d99644226442fc55c904be0f3b47c4fad6bb&
            echo -e "\033[0;33m等待\n等待\n等待下载结束后回车检测插件是否下载成功\033[0m"
            read -p " "
            if [ -f "f96ce3edc4220761.json" ]; then
                echo -e "\033[0;33m总结插件(by Darker than Black)导入成功\n\033[0m"
            else
                echo -e "\033[0;31m总结插件(by Darker than Black)导入失败！\n\033[0m"
            fi
            cd /root
            ;;
        *)
            echo "什么都没有执行"
            ;;
    esac
}

function TavernAI-extrasinstall {

	echo -e "安装TavernAI-extras（酒馆拓展）分为三步骤\n分别大致所需\n三分钟\n\033[0;33m七分钟\n\033[0m\033[0;31m十五分钟\n\033[0m具体时间视情况而定\n\033[0;31m全部安装大致所需\033[0;33m 3 \033[0m\033[0;31mG存储(不包括额外模型)\033[0m"
	echo -e "当出现\n\033[0;32m恭喜TavernAI-extras（酒馆拓展）所需环境已完全安装，可进行启动\033[0m\n则说明安装完毕"
	read -p "是否现在进行安装TavernAI-extras（酒馆拓展）[y/n]？" extrasinstallchoice
	[ "$extrasinstallchoice" = "y" ] || [ "$extrasinstallchoice" = "Y" ] && echo "已开始安装" || exit 7
	#检测环境
	if [ ! -d "/root/TavernAI-extras" ]; then
		echo "未检测到TavernAI-extras（酒馆拓展），正在通过git下载"
		git clone https://github.com/Cohee1207/TavernAI-extras /root/TavernAI-extras
		[ -d /root/TavernAI-extras ] || { echo "TavernAI-extras（酒馆拓展）安装失败，请更换网络后重试"; exit 8; }
	fi
	
	if [ ! -d "/root/myenv" ] || [ ! -f "/root/myenv/bin/activate" ]; then
		rm -rf /root/myenv
		# 更新软件包列表并安装所需软件包，重定向输出。
		echo "正在更新软件包列表..."
		apt update -y > /dev/null 2>&1

		echo -e "\033[0;33m正在安装python3虚拟环境，请稍候\n\033[0;33m(首次安装大概需要7到15分钟)..."
		read -p "是否现在进行安装？[y/n]" python3venvchoicce
		[ "$python3venvchoicce" = "y" ] || [ "$python3venvchoicce" = "Y" ] && DEBIAN_FRONTEND=noninteractive apt install python3 python3-pip python3-venv -y || exit 9
		echo "python3虚拟环境安装完成。正在创建虚拟环境"
		python3 -m venv /root/myenv
		echo "虚拟环境完成，路径为/root/myenv"
	fi
	echo -e "\033[0;31m正在安装requirements.txt所需依赖\n\033[0m(首次安装大概需要15至30分钟，最后构建时会出现长时间页面无变化，请耐心等待)..."
	read -p "是否现在进行安装？[y/n]" requirementschoice
	[ "$requirementschoice" = "y" ] || [ "$requirementschoice" = "Y" ] && { source /root/myenv/bin/activate; cd /root/TavernAI-extras; pip3 install -r requirements.txt; } || exit 10
	echo -e "？\n\033[0;32m恭喜TavernAI-extras（酒馆拓展）所需环境已完全安装，可进行启动\033[0m"
	
}

function TavernAI-extrasstart {

	if [ ! -d "/root/TavernAI-extras" ] || [ ! -d "/root/myenv" ] || [ ! -f "/root/myenv/bin/activate" ]; then
	echo "检测到当前环境不完整，先进行TavernAI-extras（酒馆拓展）安装"
	exit 11
	fi
	echo -e "\033[0;33m小提示：\n\033[0m启动对应拓展时可能需要额外下载，具体情况可以查看官方文档"
	sleep 3
	
	#进入虚拟环境
	source /root/myenv/bin/activate
	cd /root/TavernAI-extras
	#确认依赖已安装
	echo -e "正在检测依赖安装情况"
	pip3 install -r requirements.txt
	clear
	
	# 选项数组
	modules=("caption" "chromadb" "classify" "coqui-tts" "edge-tts" "embeddings" "rvc" "sd" "silero-tts" "summarize" "talkinghead" "websearch" "确认" "退出")

	# 数组中选项的状态，0 - 未选择，1 - 已选定
	declare -A selection_status

	# 初始化选项状态
	for i in "${!modules[@]}"; do
	  selection_status[$i]=0
	  selection_status[4]=1
	done

	# 函数：打印已选中的选项
	print_selected() {
	  selected_modules=()
	  for i in "${!selection_status[@]}"; do
		if [[ "${selection_status[$i]}" -eq 1 ]]; then
		  selected_modules+=("${modules[$i]}")
		fi
	  done
	  echo -e "\033[0;33m--------------------------------\033[0m"
	  echo -e "\033[0;33m使用上↑，下↓进行控制\n\033[0m回车选中，再次选中可取消选定\n\033[0;33m选择完毕后选择确认即可\033[0m"
	  echo "当前选择了: $(IFS=,; echo -e "\033[0;36m${selected_modules[*]}\033[0m")"
	}

	# 函数：显示菜单
	show_menu() {
	  print_selected
	  echo -e "\033[0;33m--------------------------------\033[0m"
	  for i in "${!modules[@]}"; do
		if [[ "$i" -eq "$current_selection" ]]; then
		  # 当前选择中的选项使用绿色显示
		  echo -e "${GREEN}${modules[$i]} (选择中)${NC}"
		elif [[ "${selection_status[$i]}" -eq 1 ]]; then
		  # 被选定的选项使用红色显示
		  echo -e "${RED}${modules[$i]} (已选定)${NC}"
		else
		  # 其他选项正常显示
		  echo -e "${modules[$i]} (未选择)"
		fi
	  done
	  echo -e "\033[0;33m--------------------------------\033[0m"
	}

	current_selection=0
	while true; do
	  show_menu
	  # 读取用户输入
	  IFS= read -rsn1 key

	  case "$key" in
		$'\x1b')
		  # 读取转义序列
		  read -rsn2 -t 0.1 key
		  case "$key" in
			'[A') # 上箭头
			  if [[ $current_selection -eq 0 ]]; then
				current_selection=$((${#modules[@]} - 1))
			  else
				((current_selection--))
			  fi
			  ;;
			'[B') # 下箭头
			  if [[ $current_selection -eq $((${#modules[@]} - 1)) ]]; then
				current_selection=0
			  else
				((current_selection++))
			  fi
			  ;;
		  esac
		  ;;
		"") # Enter键
		  if [[ $current_selection -eq $((${#modules[@]} - 2)) ]]; then
			# 选择 "确认" 选项
			break
		  elif [[ $current_selection -eq $((${#modules[@]} - 1)) ]]; then
			# 选择 "退出" 选项
			exit 12
		  else
			# 切换选择状态
			selection_status[$current_selection]=$((1 - selection_status[$current_selection]))
		  fi
		  ;;
		'q') # 按 'q' 退出
		  break
		  ;;
	  esac
	  # 清除屏幕以准备下一轮显示
	  clear
	done

	# 构建命令行
	command="python3 server.py"
	if [ ${#selected_modules[@]} -ne 0 ]; then
	  command+=" --enable-module=$(IFS=,; echo "${selected_modules[*]}")"
	fi

	# 打印最终的命令行
	clear
	echo "正在启动相关酒馆拓展:"
	echo "$command"
	eval $command
	
	
	
}
# 主菜单
echo -e "                                              
————————主菜单————————
一键安卓使用脚本
版本：$version
最新：\033[0;33m$latest_version\033[0m
运行时需要稳定的魔法网络环境"
while :
do 
    echo -e "\033[0;36m选一个执行（输入数字即可）\033[0;38m\033[0m\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;31m选项0 退出脚本\n\033[0m选项1 一键启动酒馆和clewd\n\033[0;33m选项2 单独启动Clewd\n\033[0m\033[0;37m选项3 单独启动酒馆\n\033[0m\033[0;33m选项4 Clewd设置\n\033[0m\033[0;37m选项5 酒馆设置\n\033[0m\033[0;33m选项6 安装TavernAI-extras（酒馆拓展）\n\033[0m\033[0;37m选项7 启动TavernAI-extras（酒馆拓展）\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;31m选项8 更新脚本\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;35m不要选其他选项\n\033[0m\n使用Ctrl+C可以退出当前程序\n"
    read -n 1 option
    echo 
    case $option in 
        0) 
            break ;; 
            
        1)
 	       #同时启动酒馆和clewd
            cd clewd  && bash start.sh &  cd SillyTavern && bash start.sh 
            echo "酒馆和clewd已关闭, 即将返回主菜单"
            cd ../
            ;;
        2) 
            #启动Clewd
            port=$(grep -oP '"Port":\s*\K\d+' clewd/config.js)
            echo "端口为$port, 出现 (x)Login in {邮箱} 代表启动成功, 后续出现AI无法应答等报错请检查本窗口。"
			ps -ef | grep clewd.js | awk '{print$2}' | xargs kill -9
            cd clewd
            bash start.sh
            echo "Clewd已关闭, 即将返回主菜单"
            cd ../
            ;; 
        3) 
            #启动SillyTavern
			ps -ef | grep server.js | awk '{print$2}' | xargs kill -9
            cd SillyTavern
	        bash start.sh
            echo "酒馆已关闭, 即将返回主菜单"
            cd ../
            ;; 
        4) 
            #Clewd设置
            clewdSettings
            ;; 
        5) 
            #SillyTavern设置
            sillyTavernSettings
            ;; 
		6)
			#安装TavernAI-extras（酒馆拓展）及其环境
			TavernAI-extrasinstall
			;;
		7)
			#启动TavernAI-extras（酒馆拓展）
			TavernAI-extrasstart
			;;
        8)
            # 更新脚本
            curl -O https://raw.githubusercontent.com/NocturnalRushers/claude_termux/main/sac.sh
	    echo -e "重启终端或者输入bash sac.sh重新进入脚本"
            break ;;
        *) 
            echo -e "\n\033[0;36m居然不听话，快回去\033[0m\n"
            ;;
    esac
done 
echo "已退出一键脚本，输入 bash sac.sh 可重新进入脚本"
exit
