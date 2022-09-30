# Solidity Ordered Address Set

Inspired by [Rob Hitchens' SetTypes](https://github.com/rob-Hitchens/SetTypes) and [OpenZeppelin EnumerableSet](https://docs.openzeppelin.com/contracts/3.x/api/utils#EnumerableSet), the `OrderedAddressSet` maintains the order of elements during item removal, and items can be inserted at any index.

The downside is that determining the index of a key requires scanning the list.

Includes `concat`, `slice`, and `toAddress` functions from [Gonçalo Sá's `BytesLib.sol`](https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol).

## Installation for Development

```
$ git clone https://github.com/numtel/solidity-ordered-address-set.git
$ cd solidity-ordered-address-set
$ npm install
```

Download the `solc` compiler. This is used instead of `solc-js` because it is much faster. Binaries for other systems can be found in the [Ethereum foundation repository](https://github.com/ethereum/solc-bin/).
```
$ curl -o solc https://binaries.soliditylang.org/linux-amd64/solc-linux-amd64-v0.8.13+commit.abaa5c0e
$ chmod +x solc
```

## Testing Contract

```
# Build contracts before running tests
$ npm run build-dev

$ npm test
```

## License

MIT
