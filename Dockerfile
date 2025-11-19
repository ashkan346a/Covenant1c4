# مرحله بیلد
FROM ubuntu:22.04 AS builder

# نصب پکیج‌های لازم + Go 1.23.4
RUN apt update && apt install -y git build-essential cmake wget tar gzip \
    libfontconfig1 libglib2.0-0 libtinfo5 python3 python3-pip \
    qtbase5-dev qt5-qmake libqt5websockets5-dev libspdlog-dev

# نصب Go جدید
RUN wget https://go.dev/dl/go1.23.4.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz && \
    rm go1.23.4.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

WORKDIR /havoc

# کلون کامل با submodules
RUN git clone --version && \
    git clone --recursive https://github.com/HavocFramework/Havoc.git . && \
    git pull && git submodule update --init --recursive

# فیکس نسخه Go (اگر هنوز 1.21 باشه)
RUN sed -i 's/go 1.21.*/go 1.23/' teamserver/go.mod || true

# بیلد مستقیم تیم‌سرور و کلاینت (بهترین روش ۲۰۲۵)
RUN make ts-build && make client-build

# مرحله ران‌تایم (فقط فایل‌های لازم – حجم کم)
FROM ubuntu:22.BaseImage 22.04
RUN apt update && apt install -y libfontconfig1 libglib2.0-0 libtinfo5 ca-certificates
COPY --from=builder /havoc /havoc
WORKDIR /havoc

EXPOSE 40056

# ران تیم‌سرور (user: neo pass: neo – بعداً تغییر بده)
CMD ["./havoc", "server", "-v", "--profile", "./profiles/havoc.yaotl"]
