FROM oraclelinux:9

ARG release=19
ARG update=26

RUN  dnf -y install oracle-instantclient-release-el9 && \
     dnf -y install oracle-instantclient${release}.${update}-basic oracle-instantclient${release}.${update}-devel oracle-instantclient${release}.${update}-sqlplus && \
     rm -rf /var/cache/dnf

RUN curl -fsSL https://rpm.nodesource.com/setup_22.x | bash - && \
     dnf -y install nodejs && \
     dnf clean all

ENV LD_LIBRARY_PATH=/usr/lib/oracle/${release}.${update}/client64/lib:$LD_LIBRARY_PATH
ENV PATH=/usr/lib/oracle/${release}.${update}/client64/bin:$PATH

WORKDIR /app

RUN npm install -g pnpm

COPY package.json ./
COPY pnpm-lock.yaml ./

RUN pnpm install

COPY . .

EXPOSE 3000

CMD ["pnpm", "run", "dev"]