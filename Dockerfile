FROM jrottenberg/ffmpeg:4.4-alpine

RUN apk add --no-cache tzdata curl jq fontconfig ttf-dejavu bash

ENV TZ=Africa/Algiers
ENV NEWS_1="عاجل - مواطن لقى 50 دج في سروال قديم راه يخمم يشري بيها قناة يوتيوب"
ENV NEWS_2="دراسة - 99 بالمئة من الجزائريين يضغطو على تخطي الاعلان قبل ما يبدا"
ENV NEWS_3="خبر مفرح - الباتري تاعك تكمل يوم كامل اذا ما حلتش فيسبوك"
ENV MOTIV_1="ما تستناش الوقت المناسب دير لايك ضرك"
ENV MOTIV_2="الـ 1K الاولى صعيبة من بعد تولي ساهلة معاكم"

RUN echo '#!/bin/bash' > /stream.sh && \
echo 'GOAL=5000' >> /stream.sh && \
echo 'while true; do' >> /stream.sh && \
echo 'SUBS=$(curl -s -m 10 "https://www.googleapis.com/youtube/v3/channels?part=statistics&id=$YOUTUBE_CHANNEL_ID&key=$YOUTUBE_API_KEY" | jq -r ".items[0].statistics.subscriberCount // \"0\"")' >> /stream.sh && \
echo '[[ "$SUBS" =~ ^[0-9]+$ ]] || SUBS=0' >> /stream.sh && \
echo 'PERCENT=$(( SUBS * 100 / GOAL ))' >> /stream.sh && \
echo '[ $PERCENT -gt 100 ] && PERCENT=100' >> /stream.sh && \
echo 'CURRENT_NEWS=$(echo "$NEWS_1|$NEWS_2|$NEWS_3" | tr "|" "\n" | shuf -n 1)' >> /stream.sh && \
echo 'CURRENT_MOTIV=$(echo "$MOTIV_1|$MOTIV_2" | tr "|" "\n" | shuf -n 1)' >> /stream.sh && \
echo 'PROGRESS_WIDTH=$((800 * PERCENT / 100))' >> /stream.sh && \
echo 'ffmpeg -re -f lavfi -i "color=c=0x0a0a0a:s=1920x1080:r=15" -vf "drawbox=x=0:y=0:w=1920:h=180:color=0x4a00e0@0.9:t=fill,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text=LIVE:fontcolor=0x00ff88:fontsize=48:x=80:y=65,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text=$CURRENT_NEWS:fontcolor=white:fontsize=32:x=250:y=70,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text=$CURRENT_MOTIV:fontcolor=yellow:fontsize=28:x=250:y=130,drawbox=x=50:y=280:w=$PROGRESS_WIDTH:h=40:color=0x00ff88@0.8:t=fill,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text=$SUBS / $GOAL:fontcolor=white:fontsize=36:x=800:y=280" -c:v libx264 -preset ultrafast -pix_fmt yuv420p -r 15 -g 30 -b:v 1500k -maxrate 1500k -f lavfi -i "anullsrc" -c:a aac -b:a 128k -ar 44100 -f flv rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_KEY' >> /stream.sh && \
echo 'sleep 10' >> /stream.sh && \
echo 'done' >> /stream.sh && \
chmod +x /stream.sh

CMD ["/bin/bash", "/stream.sh"]
