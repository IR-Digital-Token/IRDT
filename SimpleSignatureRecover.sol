pragma solidity ^0.4.0;

contract SimpleSignatureRecover {

    uint256 constant chainId = 5;  // for Goerli test net. Change it to suit your network.


    struct Unit {
        address to;
        uint256 value;
        uint256 fee;
        uint256 nonce;
    }
    /* if chainId is not a constant and instead dynamically initialized,
     * the hash calculation seems to be off and ecrecover() returns an unexpected signing address

    // uint256 internal chainId;
    // constructor(uint256 _chainId) public{
    //     chainId = _chainId;
    // }

    */

    // EIP-712 boilerplate begins
    event SignatureExtracted(address indexed signer, string action);

    string private constant EIP712_DOMAIN = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";
    string private constant UNIT_TYPE = "Unit(address to,uint256 value,uint256 fee,uint256 nonce)";

    // type hashes. Hash of the following strings:
    // 1. EIP712 Domain separator.
    // 2. string describing identity type
    // 3. string describing message type (enclosed identity type description included in the string)

    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(EIP712_DOMAIN));
    bytes32 private constant UNIT_TYPEHASH = keccak256(abi.encodePacked(UNIT_TYPE));

    bytes32 private DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256("VerifierApp101"), // string name
            keccak256("1"), // string version
            chainId, // uint256 chainId
            0x8c1eD7e19abAa9f23c476dA86Dc1577F1Ef401f5  // address verifyingContract
        ));


    // functions to generate hash representation of the struct objects

    function hashUnit(Unit memory unitobj) private view returns (bytes32) {
        return keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(
                    UNIT_TYPEHASH,
                    unitobj.to,
                    unitobj.value,
                    unitobj.fee,
                    unitobj.nonce
                ))
            ));
    }

    // this contains a pre-filled struct Unit and the signature values for the same struct calculated by sign.js
    function testVerify(bytes32 s, bytes32 r, uint8 v, address _to, uint256 _value, uint256 _fee, uint256 _nonce) public view returns (address) {
        Unit memory _msgobj = Unit({
        to : _to,
        value : _value,
        fee : _fee,
        nonce : _nonce
        });
        return ecrecover(hashUnit(_msgobj), v, r, s);
    }
}
