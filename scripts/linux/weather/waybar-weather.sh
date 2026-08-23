#!/usr/bin/env bash

set -u

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
cache_file="$cache_dir/weather-auckland.json"
url='https://api.open-meteo.com/v1/forecast?latitude=-36.8485&longitude=174.7633&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min&timezone=Pacific%2FAuckland&forecast_days=1'

mkdir -p "$cache_dir"

weather_json="$(curl --fail --silent --show-error --max-time 10 "$url" 2>/dev/null)" || {
    if [[ -s "$cache_file" ]]; then
        cat "$cache_file"
    else
        jq -cn '{text:"󰖐 --°C",tooltip:"奥克兰天气暂时无法获取",class:"unavailable"}'
    fi
    exit 0
}

if ! jq -e '.current.temperature_2m != null and .current.weather_code != null' >/dev/null 2>&1 <<<"$weather_json"; then
    if [[ -s "$cache_file" ]]; then
        cat "$cache_file"
    else
        jq -cn '{text:"󰖐 --°C",tooltip:"奥克兰天气数据无效",class:"unavailable"}'
    fi
    exit 0
fi

code="$(jq -r '.current.weather_code' <<<"$weather_json")"
case "$code" in
    0)           icon='󰖙'; description='晴朗' ;;
    1)           icon='󰖕'; description='大致晴朗' ;;
    2)           icon='󰖐'; description='局部多云' ;;
    3)           icon='󰖐'; description='阴天' ;;
    45|48)       icon='󰖑'; description='有雾' ;;
    51|53|55)    icon='󰖗'; description='毛毛雨' ;;
    56|57)       icon='󰙿'; description='冻毛毛雨' ;;
    61|63|65)    icon='󰖖'; description='下雨' ;;
    66|67)       icon='󰙿'; description='冻雨' ;;
    71|73|75|77) icon='󰖘'; description='下雪' ;;
    80|81|82)    icon='󰖖'; description='阵雨' ;;
    85|86)       icon='󰖘'; description='阵雪' ;;
    95|96|99)    icon='󰖓'; description='雷暴' ;;
    *)           icon='󰖐'; description='未知天气' ;;
esac

temperature="$(jq -r '.current.temperature_2m | round' <<<"$weather_json")"
apparent="$(jq -r '.current.apparent_temperature | round' <<<"$weather_json")"
humidity="$(jq -r '.current.relative_humidity_2m | round' <<<"$weather_json")"
wind="$(jq -r '.current.wind_speed_10m | round' <<<"$weather_json")"
minimum="$(jq -r '.daily.temperature_2m_min[0] | round' <<<"$weather_json")"
maximum="$(jq -r '.daily.temperature_2m_max[0] | round' <<<"$weather_json")"

output="$(jq -cn \
    --arg text "$icon ${temperature}°C" \
    --arg tooltip "奥克兰\n${description}\n体感温度：${apparent}°C\n湿度：${humidity}%\n风速：${wind} km/h\n今日：${minimum}–${maximum}°C" \
    '{text:$text,tooltip:$tooltip,class:"available"}')"

printf '%s\n' "$output" | tee "$cache_file"
