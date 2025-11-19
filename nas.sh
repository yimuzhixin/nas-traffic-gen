while true; do
    cat urls.txt | xargs -n 1 -P 9 wget -O /dev/null
done
