FROM jrottenberg/ffmpeg:4.4-alpine
WORKDIR /app
COPY video.mp4 .
CMD ffmpeg -re -stream_loop -1 -i video.mp4 -vf "scale=854:480,fps=24" -c:v libx264 -preset ultrafast -b:v 800k -maxrate 800k -bufsize 1600k -pix_fmt yuv420p -g 48 -c:a aac -b:a 96k -ar 44100 -f flv "rtmps://a.rtmps.youtube.com:443/live2/${YOUTUBE_STREAM_KEY}"
