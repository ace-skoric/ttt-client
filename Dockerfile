FROM debian:stable-slim AS builder
WORKDIR /builder
COPY . ./ttt-client
ADD https://downloads.tuxfamily.org/godotengine/4.0/beta2/Godot_v4.0-beta2_linux.x86_64.zip godot4.zip
ADD https://downloads.tuxfamily.org/godotengine/4.0/beta2/Godot_v4.0-beta2_export_templates.tpz export_templates.zip
RUN apt update && apt install -y unzip gedit
RUN mkdir target
RUN unzip godot4.zip
RUN unzip export_templates.zip
RUN rm godot4.zip export_templates.zip
RUN mv Godot_v4.0-beta2_linux.x86_64 godot4
RUN mv templates 4.0.beta2
RUN timeout 120 ./godot4 --headless -e ./ttt-client/project.godot || true
RUN mv 4.0.beta2 /root/.local/share/godot/export_templates/
RUN ./godot4 --headless --export wasm ../target/index.html --path ttt-client/

FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY --from=builder /builder/target/ .
RUN sed -i '/location \/.*$/a \\tadd_header Cross-Origin-Opener-Policy same-origin;\n\tadd_header Cross-Origin-Embedder-Policy require-corp;' /etc/nginx/conf.d/default.conf