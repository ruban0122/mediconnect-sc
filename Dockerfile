FROM dart:stable AS build-env

# Install Flutter SDK (manually)
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa && \
    git clone https://github.com/flutter/flutter.git -b stable /flutter && \
    /flutter/bin/flutter doctor

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app

COPY . .

RUN flutter pub get

RUN flutter build apk --release
