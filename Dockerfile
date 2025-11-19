# مرحله بیلد با Go جدید
FROM ubuntu:22.04 AS builder

# نصب dependencies پایه
RUN apt update && apt install -y git build-essential cmake wget tar gzip libfontconfig1 libglib2.0-0 libtinfo5 python3 python3-pip qtbase5-dev qt5-qmake libqt5websockets5-dev libspdlog-dev

# نصب Go 1.23.4 (جدیدترین تا نوامبر ۲۰۲۵)
RUN wget https://go.dev/dl/go1.23.4.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz && \
    rm go1.23.4.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# کلون و بیلد Havoc
WORKDIR /havoc
RUN git clone --recursive https://github.com/HavocFramework/Havoc.git .
# پچ go.mod برای فیکس ارور invalid go version
RUN sed -i 's/go 1.21.0/go 1.23/' teamserver/go.mod || true
# دانلود اضافی dependencies که گاهی گیر می‌کنه
RUN cd teamserver && go mod download golang.org/x/sys && go mod download github.com/ugorji/go
# بیلد تیم‌سرور و کلاینت
RUN make ts-build && make client-build

# مرحله نهایی (فقط runtime – سبک‌تر)
FROM ubuntu:22.04
RUN apt update && apt install -y libfontconfig1 libglib2.0-0 libtinfo5
COPY --from=builder /havoc /havoc
WORKDIR /havoc

EXPOSE 40056

# ران تیم‌سرور با یوزر/پسورد پیش‌فرض (بعداً از کلاینت تغییر بده)
CMD ["./havoc", "server", "--profile", "./profiles/havoc.yaotl", "-v"]
