# Guake Terminal Docker Image

Containerized version of Guake, the drop-down terminal emulator for GNOME inspired by the terminal used in Quake.

## Features
- Drop-down terminal functionality
- Multiple terminals in tabs
- Color scheme support
- Custom keyboard shortcuts
- Session persistence
- Hardware acceleration support
- X11 integration

## Prerequisites
- Docker installed
- X11 server running
- Basic understanding of Docker and container networking

## Installation

1. Pull the image:
```bash
docker pull rorqualx/guake:latest
```

2. Allow X server connections:
```bash
xhost +local:docker
```

3. Run using Docker:
```bash
docker run -it \
    --net=host \
    --env="DISPLAY" \
    --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="$HOME/.config/guake:/root/.config/guake" \
    rorqualx/guake:latest
```

## Using Docker Compose

1. Create a `docker-compose.yml`:
```yaml
version: '3.8'

services:
  guake:
    image: rorqualx/guake:latest
    network_mode: host
    environment:
      - DISPLAY=${DISPLAY}
      - GSETTINGS_SCHEMA_DIR=/usr/share/glib-2.0/schemas
      - XDG_DATA_DIRS=/usr/share:/usr/local/share:/usr/share/guake
    volumes:
      - ${HOME}/.Xauthority:/root/.Xauthority:rw
      - /tmp/.X11-unix:/tmp/.X11-unix:rw
      - ${HOME}/.config/guake:/root/.config/guake
    restart: unless-stopped
    init: true
    devices:
      - /dev/dri:/dev/dri
```

2. Start Guake:
```bash
docker compose up -d
```

## Configuration
- Configuration files are stored in `~/.config/guake`
- Custom themes can be added to `~/.config/guake/style/schemes`
- Keyboard shortcuts can be configured through the preferences dialog

## Troubleshooting

### X11 Connection Issues
If you see "Cannot open display" errors:
1. Verify X11 permissions:
```bash
xhost | grep "LOCAL:"
```
2. Check DISPLAY variable:
```bash
echo $DISPLAY
```

### Hardware Acceleration
If hardware acceleration isn't working:
1. Verify DRI device is available:
```bash
ls -l /dev/dri
```
2. Check container has access:
```bash
docker exec guake-terminal ls -l /dev/dri
```

### Configuration Issues
If settings aren't persisting:
1. Check volume mount:
```bash
docker inspect guake-terminal | grep -A 10 Mounts
```
2. Verify permissions:
```bash
ls -la ~/.config/guake
```

## Support
- GitHub Issues: [Guake/guake](https://github.com/Guake/guake/issues)
- Docker Image Issues: [rorqualx/guake-docker](https://github.com/rorqualx/guake-docker/issues)

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This Docker image is provided under the GPL-2.0 license, the same as Guake itself.

## Version History
- 3.9.0: Initial release
  - Based on Ubuntu 22.04
  - Full X11 support
  - Hardware acceleration
  - Configuration persistence

## Credits
- Original Guake project: https://github.com/Guake/guake
- Docker packaging: rorqualx
