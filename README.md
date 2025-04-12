# Minions Code Server with Cline Extension

This project provides a Dockerfile and Makefile to build and run a customized version of the `lscr.io/linuxserver/code-server` Docker image with the Cline VS Code extension (`saoudrizwan.claude-dev`) pre-installed.

## Prerequisites

- Docker installed
- Make installed

## Usage

1.  **Set Password:** Before running the container, you must set the password that code-server will use. Export it as an environment variable:
    ```bash
    export CODE_SERVER_PASSWORD='your_secret_password'
    ```

2.  **Build the Image:** Build the Docker image. This will create tags for both the version specified in the `VERSION` file and `latest`.
    ```bash
    make build
    ```

3.  **Run the Container:** Run the code-server container. This command will automatically remove any existing container with the same name (`minions-code-server-container`) before starting a new one. It mounts the local `./config` directory to `/config` inside the container for persistent configuration.
    ```bash
    make run
    ```
    You can then access code-server at `https://localhost:8443`.

4.  **(Optional) Push to Registry:** If you want to push the image to a Docker registry (like Docker Hub or GHCR), first log in to your registry (`docker login your-registry.com`), then run:
    ```bash
    # Example for Docker Hub:
    make push REGISTRY=docker.io

    # Example for GitHub Container Registry:
    # make push REGISTRY=ghcr.io
    ```
    This will push both the versioned tag and the `latest` tag.

5.  **Clean Up:** To stop and remove the running container:
    ```bash
    make clean
    ```

## Files

-   `Dockerfile`: Defines the Docker image build process.
-   `Makefile`: Contains commands (`build`, `run`, `push`, `clean`, `help`) to manage the Docker image and container.
-   `VERSION`: Contains the semantic version string used for tagging the Docker image.
-   `config/` (created on first `make run`): Directory mounted into the container for code-server configuration and workspace data.

## Development History (Prompts)

This project was created iteratively based on the following requests:

1.  Create a `Dockerfile` based on `lscr.io/linuxserver/code-server:latest` that installs the `saoudrizwan.claude-dev` extension.
2.  Create a `Makefile` with `build`, `run`, and `push` targets, following a specific `docker run` structure, using defaults and reading the password from the `CODE_SERVER_PASSWORD` environment variable.
3.  Rename the image to `minions-code-server` and read the tag from a `VERSION` file (initially `1.0.0`).
4.  Modify `build` and `push` targets to also handle the `latest` tag alongside the versioned tag.
5.  Rename the image to `wangqiang8511/minions-code-server`.
6.  Address a build failure during extension installation (modified `Dockerfile` user).
7.  Modify the `run` target to automatically remove any existing container with the same name before starting.
8.  Add a basic `README.md` explaining usage.
9.  Append this development history section to the `README.md`.
