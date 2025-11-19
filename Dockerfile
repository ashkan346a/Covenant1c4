# استفاده از تصویر پایه سبک
FROM ubuntu:22.04 AS builder

# نصب تمام dependencies لازم
RUN apt update && apt install -y git build-essential cmake golang-go libfontconfig1 libglib2.0-0 libtinfo5 python3 python3-pip

# کلون و بیلد Havoc
WORKDIR /havoc
RUN git clone --recursive https://github.com/HavocFramework/Havoc.git .
RUN cd teamserver && go mod download && go build -o teamserver .
RUN cd client && make build

# مرحله نهایی (فقط runtime)
FROM ubuntu:22.04
COPY --from=builder /havoc /havoc
WORKDIR /havoc

# پورت teamserver (Railway اتوماتیک به 443 ریدایرکت می‌کنه)
EXPOSE 40056

# ران کردن teamserver با پروفایل پیش‌فرض
CMD ["./teamserver/teamserver", "havoc", "havoc", "-v", "--profile", "./profiles/havoc.yaotl"]
