Shaman Contracts
================

This repository contains an assortment of shaman contracts that follow the
interface provided by Moloch V3 (Baal) DAOs. These can be deployed to attach to
DAOs to offer added functionality to the DAO.

The goal is to curate useful Shamans and occasionally put them through audits so
that DAOs can be confident using the shamans for their use case. Documentation
should be maintained such that it is clear how to use a shaman (which
permissions are required, how to choose parameters, etc).

Running hardhat
---------------

```bash
yarn hardhat test
yarn hardhat node
yarn hardhat run scripts/deploy.js
```
