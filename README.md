# LazyVim Docker Environment

This project provides a Dockerized environment to use LazyVim, an advanced Neovim configuration, along with essential developer tools.

---

## Features

- **LazyVim**: Predefined Neovim configuration to maximize productivity.
- **Dockerized**: Fully isolated and reproducible environment.
- **Zsh with Oh My Zsh**: Interactive shell with plugins and advanced customization.
- **Included tools**: `git`, `lazygit`, `fzf`, `ripgrep`, among others.
- **Volume mounting**: Direct access to your local files from the container.
- **Persistent configuration**: Configuration changes are retained between sessions.

---

## Requirements

- **Docker**: Make sure Docker is installed on your system.
- **Docker Compose**: Required to manage the environment.

---

## Available Scripts

- **`build.sh`**: Builds and configures the entire environment.
- **`init.sh`**: Access the container after exiting.
- **`destroy.sh`**: Stops and removes the containers but keeps the volumes.

### Execution Permissions

If the scripts do not have execution permissions, you can grant them using the following command, replacing `<script-name>` with the script file you want to execute:

```bash
chmod +x ./<script-name>
```

For example, to grant execution permissions to `build.sh`:

```bash
chmod +x ./build.sh
```

---

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/manghidev/lazyvim-docker.git
   cd lazyvim-docker
   ```

2. Build the environment using the `build.sh` script:
   ```bash
   ./build.sh
   ```

3. If you need to re-enter the container, use the `init.sh` script:
   ```bash
   ./init.sh
   ```

4. To destroy the environment (without deleting the volumes), use the `destroy.sh` script:
   ```bash
   ./destroy.sh
   ```

---

## Usage

- **Edit files**: Use LazyVim to edit your files directly from the container.
- **Customize configuration**: Modify the files in `/root/.config/nvim` to adjust LazyVim to your needs.
- **Persistence**: Configuration changes are automatically saved thanks to the Docker volume.

---

## Volume Configuration

You can edit the volumes in the `docker-compose.yml` file to add a documents folder or a USB drive according to your needs. By default, the following configurations are included:

### Documents Directory on macOS
Mount the user's Documents directory on macOS inside the container:
```yaml
- $HOME/Documents:/home/developer/Documents
```

### Documents Directory on Linux
If you are using Linux, you can mount the user's Documents directory:
```yaml
- /home/user/Documents:/home/developer/Documents
```

### USB Drive on macOS
To mount a USB drive on macOS, use the following configuration:
```yaml
- /Volumes/sdb1:/home/developer/usb
```

### USB Drive on Linux
If you need to mount a USB drive on Linux, use this configuration:
```yaml
- /dev/sdb2:/home/developer/usb
```

### Customization Example
If you want to add a specific directory where you store your projects, you can edit the `docker-compose.yml` file and add a line like this:
```yaml
- /path/to/your/project:/home/developer/projects
```
This will mount the `/path/to/your/project` directory from your local system into the container at `/home/developer/projects`.

### Note
You can modify these paths directly in the `docker-compose.yml` file to adapt them to your operating system and specific needs. Make sure the local paths exist on your system before starting the container.

---

## Contributions

Contributions are welcome! If you have ideas or improvements, feel free to open an issue or submit a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

## Author

Created by ManghiDev. For more information, visit [manghi.dev](https://manghi.dev).