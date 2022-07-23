# Attributable

A proposal for a standard approach to attributes on chain

## Premise

In 2021, I proposed a standard for on-chain attributes for NFT at https://github.com/ndujaLabs/erc721playable

It was using an array of uint8 to store generic attributes.

After a few iterations and attempt to implement it I realized that it is very unlikely that a player, for example, a game can be fine with just storing uint8 values. Most likely it will need multiple types that defies the advantages of that approach.

Investigating the possible alternatives, I reach the conclusion that the best way to have generic values is to encode them in an array of uint256, asking the player to translate them in parameters that can be understood, for example, by a marketplace.

Let's say that you have an NFT that start in a game at level 2, but later can be leveled up. Where do you store the info about the level? If you put it in the JSON metadata, you break one of the rules of the NFT, the immutability of the attributes (very important for collectors). The solution is to split the attributes in two categories: mutable and immutable attributes.


## Set up you environment

### 1 - Node

Install [node](https://nodejs.org/). Best way on Linux and Mac is to use [nvm](https://github.com/nvm-sh/nvm).

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```

The script clones the nvm repository to `~/.nvm`, and attempts to add the source lines from the snippet below to the correct profile file (`~/.bash_profile`, `~/.zshrc`, `~/.profile`, or `~/.bashrc`).

```

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
```

Opening a new terminal, you should be able to access nvm. If not, add the lines above in your profile file, and source it.

When nvm is installed, you can install node with a command like

```
nvm install v16
```

The advantage of using nvm is that it does not install it as root (very important for security) and allows you to install many versions of Node and jump between them when you need it.

### 2 - Pnpm and dependencies

Install the packages. In this repo we use [pnpm](https://pnpm.io/) as favorite package manager, because it is faster than npm, saves lot of spaces reusing packages, manages monorepos, etc.

```
npm i -g pnpm
```

Install the dependencies

```
pnpm i
```

### 3 - Dev blockchain

You can launch an EVM node with

```
npx hardhat node
```

the problem is that every time you restart it, you reset your environment. This is not optimal. It'd be better to be able to have a local blockchain that maintains contracts, transactions, etc. so that you can evolve your work.
To do so, we prefer to use Ganache.

Go to https://trufflesuite.com/ganache/, download Ganache and install it.

Launch it. Then, configure a server compatible with Hardhat node. To do so, in Workspaces, click on NEW WORKSPACE (Ethereum). In the tab Server, set the port number to 8545 and the network ID to 1337. In the tab Account&Keys, use the standard Hardhat test mnemonic:

```
test test test test test test test test test test test junk
```

When done, run the server. Now, you have a local blockchain ready for the job.

### 4 - Tasks

To compile the smart contracts

```
npx hardhat compile
```

To test:

```
npx hardhat test
```

To deploy the nft to Ganache

```
bin/deploy.sh nft localhost
```

# Copyright

(c) 2022, Francesco Sullo <francesco@sullo.co>

# License

MIT
