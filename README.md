# Custom Renderer for bytes32 txn id metadata references

### `initialize(base, postfix, contractURI)`

### URI Output:

`tokenURI => concat(base, bytes32(txnhash) [no 0x prefix], postfix)`

`contractURI => contractURI`

