while true; do printf "HTTP/1.1 200 OK\n\n$(ip route get 1 | awk '{print $(NF-2);exit}')" | nc -q 0 -l -p 9998; done
