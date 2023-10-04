# ToxRox Ejector

Welcome to the [**ToxRox**](https://github.com/ZelkZelk/txrx) ejector project.

If you're here, you're most probably interested in `getting started`.

## Getting started

Most of this was developed/tested using `Ubuntu 22.04.3 LTS`, however is not strictly necessary as everything is dockerized anyway.

You're still going to need:

- git
- docker engine
- npm
- basic programs that an `unix-like` environment should bring: cp, cat, sed, tr, rm.

### The setup script

**Note:** the script will use the name of the current `folder` to namespace everything, you might want to rename the folder to your actual project name.

By running:

```
./setup.sh
```

You will get an `ejected` project. You will also notice:

- a `backend` folder, this is the ejected boilerplate backend
- a `frontend` folder, this is the ejected boilerplate frontend
- a `docker-compose.yml` along with a `Dockerfile`, both ready to be deployed
- a `Makefile`, ready to help you out during the deployment
- the `.git` folder is gone, this is made on purpose as you should commit into your own repository at this point

**Note:** the `setup` script was developed/tested using `Ubuntu 22.04.3 LTS` and according to ChatGPT:

```
The Bash script you provided appears to be focused on setting up a project environment, specifically for a Git repository where you have submodules and want to make some modifications based on specific conditions. Let's analyze its portability:

1. **Git Dependency**: The script heavily relies on Git commands like `git remote get-url`, `git submodule init`, and `git submodule update`. These commands should work on any system with Git installed, which is generally portable across different Unix-like systems (Linux, macOS) and even Windows if Git for Windows is installed. However, ensure that Git is available and properly configured on the system where you intend to run this script.

2. **File Manipulation**: The script uses basic file manipulation operations like `cp`, `cat`, `sed`, `tr`, and `rm`. These commands are common across Unix-like systems and should work well on most of them.

3. **Node.js Dependencies**: There are some npm commands used (`npm install`). These commands are portable as long as Node.js and npm are installed correctly on the target system. Node.js and npm are generally available for various platforms, but you should ensure they are installed before running the script.

4. **Conditional Logic**: The script uses conditional constructs like `if`, `[[ ... ]]`, and `==`, which are common in Bash scripting and should work consistently on different systems.

5. **File Existence Checks**: The script checks for the existence of specific files and directories using `-f` and `-d` flags. These checks should be portable across different Unix-like systems.

6. **Text Processing**: The script utilizes `sed` for text processing. The usage appears to be relatively straightforward and should work on most systems.

7. **File Path Manipulation**: The script assumes the availability of the `PWD` command for working with file paths. This command should work consistently across Unix-like systems.

8. **Tricky Line Break Handling**: There's a section of the script that uses `tr` and `sed` to handle line breaks. This part may require some attention, as handling line breaks can vary slightly between systems. It should generally work, but you might want to test it thoroughly.

Overall, the script should be reasonably portable across Unix-like systems, assuming that Git, Node.js, npm, and common Unix utilities like `sed`, `tr`, and `rm` are available and correctly configured on the target systems. However, you should always test the script on your target platforms to ensure it works as expected.
```

**Note:** if you ran the script again, nothing will happen as it won't override existing files/folders.

## Bootstrap it

We will describe the initial sequence to get things started.

### Redis containers

We absolutely need Redis for both message consumption and `p2p` internal communication:

```
make redis
make redis-p2p
```

### Websocket

By default it will listen on port `8080`, make sure this port is available or feel free to change it to fit your needs.

```
make websocket
```

### Dispatcher

Enters a lone `dispatcher` into the game.

```
make dispatcher
```

### RPC

The `ejected` setup brings two `rpc` services, one `general` and also the `auth` rpc.

```
make rpc
make rpc-auth
```

### Database

The boilerplate `backend` uses PostgreSQL as storage for a very simple `login` implementation.

```
make postgres
```

After this you can create, migrate and seed the database:

```
cd backend
npm i
make bootstrap
```

### Playground

To try the setup out, the ejected `frontend` offers a `playground` page. Make sure to run the frontend's `Makefile`.

By default the `dev server` will listen on port `3000`, make sure it is available or change it to fit your needs.

```
cd ../frontend
npm i
make dev
```

Go to [the playground](http://127.0.0.1:3000/playground) and try some basic commands included within the boilerplate `backend`.

#### Ping

Will pong back whatever you enter:

- ping 123
- pong 123

#### Time

Will respond the actual unix timestamp in milliseconds:

- time
- 1694998971212

#### Login

Attempts to authenticate the `websocket` connection.

**Note:** the login command below should authenticate you based on the default database `seeder`.

- login klez 12345
- authorized 1695006160821 87c07ae0-6647-452c-9c68-983245b852f3 ADMIN

#### Authorize

You can use the `token` received to check the authorization status.

- authorize klez 87c07ae0-6647-452c-9c68-983245b852f3
- authorized 1695006232254 87c07ae0-6647-452c-9c68-983245b852f3 ADMIN

#### Me

Fetches info about the current `authorized` user.

- me
- you
- `{"id":"1","handle":"klez","email":"..."}`

**Note:** interestingly enough, this endpoint returns a `json` on a new line.

#### Logout

- logout
- deauthorized

#### Me (while not authorized)

We didn't blunder this out:

- me
- forbidden

**Note:** You can also have a glance of the [incomplete backoffice](http://127.0.0.1:3000/backoffice). They do share the same `dev server`.

## What's next?

- Initialize your `git` repository and start implementing the `backend` or `frontend` to fit your needs. Don't forget to push!

- Check out the `docker-compose` file and customize it to fit your needs. You can tune the parameters up, add more containers, separate `rpc`, add more `consumers` to a specific `consuming group`, etc.

- Keep an eye on the [**ToxRox**](https://github.com/ZelkZelk/txrx) core project as many improvements are acoming!

**Note:** the boilerplate `frontend` can be totally ditched and use whatever you want to build it from the scratch. The `playground` is too cool though and probably a keeper.
