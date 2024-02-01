#!/bin/bash

version="Ver2.7.3"
latest_version=$(curl -s https://raw.githubusercontent.com/NocturnalRushers/claude_termux/main/VERSION)
#

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
        echo "node下载失败，请自己尝试手动下载"
        exit 1

  fi
fi

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
        echo -e "\033[0;33m 因网络波动预设文件下载失败了，更换网络后再试\n\033[0m"
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
    echo -e "\033[0;36m选一个执行\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;33m选项1 查看 config.js 配置文件\n\033[0m\033[0;37m选项2 使用 Vim 编辑 config.js\n\033[0m\033[0;33m选项3 添加 Cookies\n\033[0m\033[0;37m选项4 修改 Clewd 密码\n\033[0m\033[0;33m选项5 修改 Clewd 端口\n\033[0m\033[0;37m选项6 修改 Cookiecounter\n\033[0m\033[0;33m选项7 修改 rProxy\n\033[0m\033[0;37m选项0 删除现有clewd，下载最新测试修改版clewd\n\033[0m\033[0;33m--------------------------------------\n\033[0m"
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
                    echo -e "你的cookies应该是:\n"
                    echo "$cookies"
                    # Format cookies, one per line with quotes
                    cookies=$(echo "$cookies" | tr ' ' '\n' | sed -e 's/^/"/; s/$/"/g')
                    # Join into array
                    cookie_array=$(echo "$cookies" | tr '\n' ',' | sed 's/,$//')
                    # Update config.js
                    sed -i "/\"CookieArray\"/s/\[/\[$cookie_array\,/" ./$clewd_dir/config.js
                    echo "Cookies成功被添加到config.js文件了"
                else
                    echo "没有找到cookie，如果要退出输入请按Ctrl+D（点击termux界面下部的Ctrl，然后点击自己键盘的D)"
                fi
            done
            echo "cookies成功输入了"
            ;;
        4) 
            # 修改 Clewd 密码
            read -p "是否修改密码?(y/n)" choice
            if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
                # 读取用户输入的新密码
                read -p "请输入新密码\n（本地部署一般不需要设密码吧）:" new_pass

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
            echo "切换Cookie的频率, 默认为3(每3次切换,数字越大，单个账号使用条数越多), 改为-1进入测试Cookie模式"
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
        0)
            cd /root
	        rm -rf clewd
            git clone -b test https://github.com/teralomaniac/clewd.git
	        cd clewd
            bash start.sh
	        cd /root
            ;;
        *)
            echo "什么都没有执行"
            ;;
    esac
}

function sillyTavernSettings {
    # 4. SillyTavern设置
	echo -e "\033[0;36m选一个执行\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;33m选项1 修改酒馆端口\n\033[0m\033[0;37m选项2 保留数据更新酒馆最新版本\n\033[0m\033[0;33m选项3 导入最新整合预设\n\033[0m\033[0;37m选项4 导入DC总结插件by(Darker than Black)\n\033[0m\033[0;33m--------------------------------------\n\033[0m"
    read -n 1 option
    echo
    case $option in 
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
            esac
            ;;
        3)
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
        4)
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

# 主菜单
echo -e "  
————————主菜单————————
一键安卓使用脚本
版本：$version
最新：\033[0;33m$latest_version\033[0m
运行时需要稳定的魔法网络环境"
while :
do 
    echo -e "\033[0;36m 请输入数字进行执行（输入数字即可）\033[0;38m \033[0m\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;31m选项0 退出脚本\n\033[0m选项1 一键启动酒馆和clewd\n\033[0;33m选项2 单独启动Clewd\n\033[0m\033[0;37m选项3 单独启动酒馆\n\033[0m\033[0;33m选项4 Clewd设置\n\033[0m\033[0;37m选项5 酒馆配置\n\033[0m\033[0;31m选项6 更新脚本\n\033[0m\033[0;33m--------------------------------------\n\033[0m\033[0;35m不要选其他选项\n\033[0m\n使用Ctrl+C可以退出当前程序\n"
    read -n 1 option
    echo 
    case $option in 
        0) 
            break ;; 
	1) #同时启动酒馆和clewd
             #启动SillyTavern和clewd
            cd SillyTavern 
	      bash start.sh &
            cd clewd 
	      bash start.sh 
            echo "酒馆和clewd已关闭, 即将返回主菜单"
            cd ../
            ;; 
        2) #启动Clewd
            port=$(grep -oP '"Port":\s*\K\d+' clewd/config.js)
            echo "端口为$port, 出现 (x)Login in {邮箱} 代表启动成功, 后续出现AI无法应答等报错请检查本窗口。"
            cd clewd
            bash start.sh
            echo "Clewd已关闭, 即将返回主菜单"
            cd ../
            ;; 
        3) 
            #启动SillyTavern
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
